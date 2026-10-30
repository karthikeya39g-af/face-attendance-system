from pydantic import BaseModel, Field


class EmployeeCreate(BaseModel):
    employee_code: str = Field(min_length=1, max_length=32)
    name: str = Field(min_length=1, max_length=128)
    office_code: str
    department: str | None = None
    designation: str | None = None
    email: str | None = None
    phone: str | None = None


class EmployeeUpdate(BaseModel):
    name: str | None = None
    office_code: str | None = None
    department: str | None = None
    designation: str | None = None
    email: str | None = None
    phone: str | None = None
