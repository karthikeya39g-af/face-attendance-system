from pydantic import BaseModel, Field


class EnrollmentStart(BaseModel):
    employee_code: str = Field(min_length=1, max_length=32)
    name: str = Field(min_length=1, max_length=128)
    office_code: str


class EnrollmentComplete(BaseModel):
    session_id: str
