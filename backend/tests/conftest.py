import os
import tempfile

_tmp = tempfile.mkdtemp()
os.environ.setdefault("DATABASE_URL", f"sqlite:///{_tmp}/test.db")
os.environ["API_KEY"] = ""
os.environ["ENROLLMENT_TARGET"] = "5"
