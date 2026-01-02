import chromadb
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from uuid import uuid4
from typing import List
from main import client

app = FastAPI()

chroma_client = chromadb.PersistentClient(path="./chroma_db")
try:
    collection = chroma_client.get_or_create_collection(name="documents")
except AttributeError:
    try:
        collection = chroma_client.get_collection(name="documents")
    except Exception:
        collection = chroma_client.create_collection(name="documents")

class DocumentsRequest(BaseModel):
    texts: List[str]

class QueryRequest(BaseModel):
    query: str

@app.post("/addCollection")
async def add_to_collection(request: DocumentsRequest):
    texts = request.texts
    if not texts:
        raise HTTPException(status_code=400, detail="No texts provided")

    resp = client.embeddings.create(input=texts, model="text-embedding-3-small")
    embeddings = [d.embedding for d in resp.data]
    ids = [str(uuid4()) for _ in texts]
    collection.add(documents=texts, embeddings=embeddings, ids=ids)
    return {"ids": ids}

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
        result = collection.query(query_embeddings=[q_emb], n_results=1)

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
