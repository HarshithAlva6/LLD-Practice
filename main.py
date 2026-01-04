#🏗️ Step 1: The Python "Brain" (FastAPI + Embeddings)
#We’ll start here because your Swift app needs something to talk to.
#
#Theory: The Transformation
#When you send a sentence to the backend, we convert it into a Vector (a list of numbers).
#
#The Goal: Use Cosine Similarity to see how "close" two vectors are in 3D space.
#
#The Task:
#Initialize FastAPI: Create a basic app.
#
#Token Count: Use tiktoken to print the cost/size of the incoming string.
#
#Embed & Compare: Use an OpenAI client to get embeddings and write a math function to compare them.

#python -m venv .vir
#source .vir/Scripts/activate
#pip install --upgrade pip
#pip install fastapi tiktoken numpy openai uvicorn
#Get keys from https://platform.openai.com/api-keys

#pip install chromadb python-dotenv
#pip install uvicorn 

from fastapi import FastAPI
from pydantic import BaseModel
import tiktoken
import numpy as np
from openai import OpenAI
from dotenv import load_dotenv
import os

app = FastAPI()
load_dotenv()  # Load environment variables from .env file
api_key = os.getenv("OPENAI_API_KEY")
client = OpenAI(api_key=api_key)

class TextRequest(BaseModel):
    text: str
    
def cosine_similarity(vec1, vec2):
    dot_product = np.dot(vec1, vec2)
    norm_a = np.linalg.norm(vec1)
    norm_b = np.linalg.norm(vec2)
    return dot_product / (norm_a * norm_b)

@app.post("/embed")
async def embed_text(request: TextRequest):
    # Token Count
    encoding = tiktoken.get_encoding("cl100k_base")
    tokens = encoding.encode(request.text)
    token_count = len(tokens)

    # Get Embedding
    response = client.embeddings.create(
        input=request.text,
        model="text-embedding-3-small"
    )
    embedding = response.data[0].embedding

    return {
        "token_count": token_count,
        "embedding": embedding
    }

# To run the app, use the command:
# uvicorn main:app --reload