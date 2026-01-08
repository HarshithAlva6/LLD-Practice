import chromadb
from fastapi import FastAPI, HTTPException
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from uuid import uuid4
from typing import List
from main import client
from data import DocumentsRequest, QueryRequest, ChatRequest

app = FastAPI()

chroma_client = chromadb.PersistentClient(path="./chroma_db")
try:
    collection = chroma_client.get_or_create_collection(name="documents")
except AttributeError:
    try:
        collection = chroma_client.get_collection(name="documents")
    except Exception:
        collection = chroma_client.create_collection(name="documents")


async def stream_generation(messages):
    stream = client.chat.completions.create(
        model="gpt-4o",
        messages=messages,
        stream=True
    )

    for chunk in stream:
        if chunk.choices[0].delta.content:
            content = chunk.choices[0].delta.content
            yield f"data: {content}\n\n"
    yield "data: [DONE]\n\n"

@app.post("/addCollection")
async def add_to_collection(request: DocumentsRequest):
    chunks = chunk_text(request.texts)
    if not chunks:
        raise HTTPException(status_code=400, detail="No texts provided")

    resp = client.embeddings.create(input=chunks, model="text-embedding-3-small")
    embeddings = [d.embedding for d in resp.data]
    ids = [str(uuid4()) for _ in chunks]
    metadata = [{"source": "policies.pdf", "chunk_index": i} for i in range(len(chunks))]
    collection.add(
        documents=chunks,
        embeddings=embeddings,
        ids=ids,
        metadatas=metadata
    )
    return {"ids": ids}

def chunk_text(text: str, chunk_size: int = 500, overlap: int = 50) -> List[str]:
    chunks = []
    start = 0
    while start < len(text):
        end = start+chunk_size
        chunks.append(text[start:end])
        start += chunk_size - overlap
    return chunks

@app.post("/query")
async def query_collection(request: QueryRequest):
    if not request.query:
        raise HTTPException(status_code=400, detail="Empty query")

    # Retrieve (The 'R' in RAG)
    resp = client.embeddings.create(input=request.query, model="text-embedding-3-small")
    q_emb = resp.data[0].embedding

    try:
        result = collection.query(queries=[q_emb], n_results=1)
    except TypeError:
        result = collection.query(query_embeddings=[q_emb], n_results=3) # Multi Chunk Retrieval / Top "K" Shift

    # Extract the top document
    top_doc = result["documents"][0][0] if result["documents"] and result["documents"][0] else None
    
    if not top_doc:
        return {"answer": "I couldn't find any relevant documents to answer your question.", "source": None}

    # 2. Generate (The 'G' in RAG)
    # We use the retrieved document as 'Context' for the LLM
    generation = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "system", 
                "content": "You are a helpful assistant. Answer the question using ONLY the provided context. If the answer isn't there, say you don't know."
            },
            {
                "role": "user", 
                "content": f"Context: {top_doc}\n\nQuestion: {request.query}"
            }
        ]
    )
    answer = generation.choices[0].message.content

    return {
        "answer": answer,
        "source_document": top_doc
    }

@app.post("/chat")
async def chat_with_context(request: ChatRequest, stream: bool = False):
    query = request.messages[-1].content if request.messages else ""
    if not query:
        raise HTTPException(status_code=400, detail="Empty query")
    
    # Retrieve (The 'R' in RAG)
    resp = client.embeddings.create(input=query, model="text-embedding-3-small")
    q_emb = resp.data[0].embedding
    try:
        result = collection.query(queries=[q_emb], n_results=3)
    except TypeError:
        result = collection.query(query_embeddings=[q_emb], n_results=3) # Multi Chunk Retrieval / Top "K" Shift

    top_docs = result["documents"][0] if result["documents"] else []
    top_doc = "\n---\n".join(top_docs)

    top_metadata = result["metadatas"][0][0] if result["metadatas"] else []
    llm_message = [
        {"role": "system", "content": f"You are a helpful assistant. Use the following context snippets to answer:{top_doc}"}
    ] + [{"role": msg.role, "content": msg.content} for msg in request.messages]

    if stream:
        return StreamingResponse(stream_generation(llm_message), media_type="text/event-stream")
    else:
        generation = client.chat.completions.create(
            model="gpt-4o",
            messages=llm_message
         )

    return {
        "answer": generation.choices[0].message.content,
        "source_document": top_docs[0] if top_docs else "No source found",
        "metadata": top_metadata
    }
