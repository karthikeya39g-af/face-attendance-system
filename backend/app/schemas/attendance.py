from pydantic import BaseModel


class ManualAttendance(BaseModel):
    employee_code: str
