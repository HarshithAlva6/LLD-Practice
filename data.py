class DocumentsRequest(BaseModel):
    texts: List[str]

class QueryRequest(BaseModel):
    query: str

class Message(BaseModel):
    role: str # "user" or "system"
    content: str

class ChatRequest(BaseModel):
    messages: List[Message] # List of messages in the chat
