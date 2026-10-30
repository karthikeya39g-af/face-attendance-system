--
-- PostgreSQL database dump
--

\restrict OKk29DKa0z8WtmULsU8qAsm4Yk5vMIYTkfmUCWZQgzusHX0hiSRLDfur2bOgE36

-- Dumped from database version 17.11 (Debian 17.11-0+deb13u1)
-- Dumped by pg_dump version 17.11 (Debian 17.11-0+deb13u1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.salary_profiles DROP CONSTRAINT IF EXISTS salary_profiles_employee_id_fkey;
ALTER TABLE IF EXISTS ONLY public.payroll_records DROP CONSTRAINT IF EXISTS payroll_records_payroll_period_id_fkey;
ALTER TABLE IF EXISTS ONLY public.payroll_records DROP CONSTRAINT IF EXISTS payroll_records_employee_id_fkey;
ALTER TABLE IF EXISTS ONLY public.payroll_audit_log DROP CONSTRAINT IF EXISTS payroll_audit_log_payroll_period_id_fkey;
ALTER TABLE IF EXISTS ONLY public.payroll_adjustments DROP CONSTRAINT IF EXISTS payroll_adjustments_payroll_record_id_fkey;
ALTER TABLE IF EXISTS ONLY public.leave_requests DROP CONSTRAINT IF EXISTS leave_requests_leave_type_id_fkey;
ALTER TABLE IF EXISTS ONLY public.leave_requests DROP CONSTRAINT IF EXISTS leave_requests_employee_id_fkey;
ALTER TABLE IF EXISTS ONLY public.face_embeddings DROP CONSTRAINT IF EXISTS face_embeddings_employee_id_fkey;
ALTER TABLE IF EXISTS ONLY public.employees DROP CONSTRAINT IF EXISTS employees_office_id_fkey;
ALTER TABLE IF EXISTS ONLY public.employee_shifts DROP CONSTRAINT IF EXISTS employee_shifts_shift_id_fkey;
ALTER TABLE IF EXISTS ONLY public.employee_shifts DROP CONSTRAINT IF EXISTS employee_shifts_employee_id_fkey;
ALTER TABLE IF EXISTS ONLY public.attendance DROP CONSTRAINT IF EXISTS attendance_office_id_fkey;
ALTER TABLE IF EXISTS ONLY public.attendance_events DROP CONSTRAINT IF EXISTS attendance_events_office_id_fkey;
ALTER TABLE IF EXISTS ONLY public.attendance_events DROP CONSTRAINT IF EXISTS attendance_events_employee_id_fkey;
ALTER TABLE IF EXISTS ONLY public.attendance DROP CONSTRAINT IF EXISTS attendance_employee_id_fkey;
DROP INDEX IF EXISTS public.ix_salary_profiles_employee_id;
DROP INDEX IF EXISTS public.ix_payroll_records_payroll_period_id;
DROP INDEX IF EXISTS public.ix_payroll_records_employee_id;
DROP INDEX IF EXISTS public.ix_payroll_periods_status;
DROP INDEX IF EXISTS public.ix_payroll_audit_log_payroll_period_id;
DROP INDEX IF EXISTS public.ix_payroll_adjustments_payroll_record_id;
DROP INDEX IF EXISTS public.ix_offices_code;
DROP INDEX IF EXISTS public.ix_leave_requests_status;
DROP INDEX IF EXISTS public.ix_leave_requests_start_date;
DROP INDEX IF EXISTS public.ix_leave_requests_employee_id;
DROP INDEX IF EXISTS public.ix_holidays_holiday_date;
DROP INDEX IF EXISTS public.ix_face_embeddings_employee_id;
DROP INDEX IF EXISTS public.ix_employees_office_id;
DROP INDEX IF EXISTS public.ix_employees_employee_code;
DROP INDEX IF EXISTS public.ix_employee_shifts_employee_id;
DROP INDEX IF EXISTS public.ix_attendance_events_event_type;
DROP INDEX IF EXISTS public.ix_attendance_events_employee_id;
DROP INDEX IF EXISTS public.ix_attendance_events_created_at;
DROP INDEX IF EXISTS public.ix_attendance_employee_id;
DROP INDEX IF EXISTS public.ix_attendance_attendance_date;
ALTER TABLE IF EXISTS ONLY public.work_shifts DROP CONSTRAINT IF EXISTS work_shifts_pkey;
ALTER TABLE IF EXISTS ONLY public.work_shifts DROP CONSTRAINT IF EXISTS work_shifts_name_key;
ALTER TABLE IF EXISTS ONLY public.salary_profiles DROP CONSTRAINT IF EXISTS uq_salary_emp_from;
ALTER TABLE IF EXISTS ONLY public.payroll_periods DROP CONSTRAINT IF EXISTS uq_payroll_period;
ALTER TABLE IF EXISTS ONLY public.payroll_records DROP CONSTRAINT IF EXISTS uq_payroll_emp_period;
ALTER TABLE IF EXISTS ONLY public.attendance DROP CONSTRAINT IF EXISTS uq_employee_day;
ALTER TABLE IF EXISTS ONLY public.salary_profiles DROP CONSTRAINT IF EXISTS salary_profiles_pkey;
ALTER TABLE IF EXISTS ONLY public.payroll_records DROP CONSTRAINT IF EXISTS payroll_records_pkey;
ALTER TABLE IF EXISTS ONLY public.payroll_periods DROP CONSTRAINT IF EXISTS payroll_periods_pkey;
ALTER TABLE IF EXISTS ONLY public.payroll_audit_log DROP CONSTRAINT IF EXISTS payroll_audit_log_pkey;
ALTER TABLE IF EXISTS ONLY public.payroll_adjustments DROP CONSTRAINT IF EXISTS payroll_adjustments_pkey;
ALTER TABLE IF EXISTS ONLY public.offices DROP CONSTRAINT IF EXISTS offices_pkey;
ALTER TABLE IF EXISTS ONLY public.leave_types DROP CONSTRAINT IF EXISTS leave_types_pkey;
ALTER TABLE IF EXISTS ONLY public.leave_types DROP CONSTRAINT IF EXISTS leave_types_code_key;
ALTER TABLE IF EXISTS ONLY public.leave_requests DROP CONSTRAINT IF EXISTS leave_requests_pkey;
ALTER TABLE IF EXISTS ONLY public.holidays DROP CONSTRAINT IF EXISTS holidays_pkey;
ALTER TABLE IF EXISTS ONLY public.face_embeddings DROP CONSTRAINT IF EXISTS face_embeddings_pkey;
ALTER TABLE IF EXISTS ONLY public.employees DROP CONSTRAINT IF EXISTS employees_pkey;
ALTER TABLE IF EXISTS ONLY public.employee_shifts DROP CONSTRAINT IF EXISTS employee_shifts_pkey;
ALTER TABLE IF EXISTS ONLY public.attendance DROP CONSTRAINT IF EXISTS attendance_pkey;
ALTER TABLE IF EXISTS ONLY public.attendance_events DROP CONSTRAINT IF EXISTS attendance_events_pkey;
ALTER TABLE IF EXISTS ONLY public.app_settings DROP CONSTRAINT IF EXISTS app_settings_pkey;
ALTER TABLE IF EXISTS public.work_shifts ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.salary_profiles ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.payroll_records ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.payroll_periods ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.payroll_audit_log ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.payroll_adjustments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.offices ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.leave_types ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.leave_requests ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.holidays ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.face_embeddings ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.employees ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.employee_shifts ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.attendance_events ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.attendance ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.work_shifts_id_seq;
DROP TABLE IF EXISTS public.work_shifts;
DROP SEQUENCE IF EXISTS public.salary_profiles_id_seq;
DROP TABLE IF EXISTS public.salary_profiles;
DROP SEQUENCE IF EXISTS public.payroll_records_id_seq;
DROP TABLE IF EXISTS public.payroll_records;
DROP SEQUENCE IF EXISTS public.payroll_periods_id_seq;
DROP TABLE IF EXISTS public.payroll_periods;
DROP SEQUENCE IF EXISTS public.payroll_audit_log_id_seq;
DROP TABLE IF EXISTS public.payroll_audit_log;
DROP SEQUENCE IF EXISTS public.payroll_adjustments_id_seq;
DROP TABLE IF EXISTS public.payroll_adjustments;
DROP SEQUENCE IF EXISTS public.offices_id_seq;
DROP TABLE IF EXISTS public.offices;
DROP SEQUENCE IF EXISTS public.leave_types_id_seq;
DROP TABLE IF EXISTS public.leave_types;
DROP SEQUENCE IF EXISTS public.leave_requests_id_seq;
DROP TABLE IF EXISTS public.leave_requests;
DROP SEQUENCE IF EXISTS public.holidays_id_seq;
DROP TABLE IF EXISTS public.holidays;
DROP SEQUENCE IF EXISTS public.face_embeddings_id_seq;
DROP TABLE IF EXISTS public.face_embeddings;
DROP SEQUENCE IF EXISTS public.employees_id_seq;
DROP TABLE IF EXISTS public.employees;
DROP SEQUENCE IF EXISTS public.employee_shifts_id_seq;
DROP TABLE IF EXISTS public.employee_shifts;
DROP SEQUENCE IF EXISTS public.attendance_id_seq;
DROP SEQUENCE IF EXISTS public.attendance_events_id_seq;
DROP TABLE IF EXISTS public.attendance_events;
DROP TABLE IF EXISTS public.attendance;
DROP TABLE IF EXISTS public.app_settings;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: app_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_settings (
    key character varying(64) NOT NULL,
    value json NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.app_settings OWNER TO postgres;

--
-- Name: attendance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attendance (
    id integer NOT NULL,
    employee_id integer NOT NULL,
    office_id integer NOT NULL,
    attendance_date date NOT NULL,
    check_in_time timestamp with time zone,
    check_out_time timestamp with time zone,
    check_in_similarity double precision,
    check_out_similarity double precision,
    status character varying(20) NOT NULL
);


ALTER TABLE public.attendance OWNER TO postgres;

--
-- Name: attendance_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attendance_events (
    id integer NOT NULL,
    employee_id integer,
    office_id integer,
    event_type character varying(40) NOT NULL,
    similarity double precision,
    details json,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.attendance_events OWNER TO postgres;

--
-- Name: attendance_events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.attendance_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.attendance_events_id_seq OWNER TO postgres;

--
-- Name: attendance_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.attendance_events_id_seq OWNED BY public.attendance_events.id;


--
-- Name: attendance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.attendance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.attendance_id_seq OWNER TO postgres;

--
-- Name: attendance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.attendance_id_seq OWNED BY public.attendance.id;


--
-- Name: employee_shifts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee_shifts (
    id integer NOT NULL,
    employee_id integer NOT NULL,
    shift_id integer NOT NULL,
    effective_from date NOT NULL,
    effective_to date
);


ALTER TABLE public.employee_shifts OWNER TO postgres;

--
-- Name: employee_shifts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employee_shifts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employee_shifts_id_seq OWNER TO postgres;

--
-- Name: employee_shifts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employee_shifts_id_seq OWNED BY public.employee_shifts.id;


--
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employees (
    id integer NOT NULL,
    employee_code character varying(32) NOT NULL,
    name character varying(128) NOT NULL,
    office_id integer NOT NULL,
    is_active boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    department character varying(64),
    designation character varying(64),
    email character varying(128),
    phone character varying(32)
);


ALTER TABLE public.employees OWNER TO postgres;

--
-- Name: employees_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employees_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employees_id_seq OWNER TO postgres;

--
-- Name: employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employees_id_seq OWNED BY public.employees.id;


--
-- Name: face_embeddings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.face_embeddings (
    id integer NOT NULL,
    employee_id integer NOT NULL,
    embedding bytea NOT NULL,
    model_name character varying(64) NOT NULL,
    blur_score double precision,
    liveness_score double precision,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.face_embeddings OWNER TO postgres;

--
-- Name: face_embeddings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.face_embeddings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.face_embeddings_id_seq OWNER TO postgres;

--
-- Name: face_embeddings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.face_embeddings_id_seq OWNED BY public.face_embeddings.id;


--
-- Name: holidays; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.holidays (
    id integer NOT NULL,
    holiday_date date NOT NULL,
    name character varying(128) NOT NULL
);


ALTER TABLE public.holidays OWNER TO postgres;

--
-- Name: holidays_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.holidays_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.holidays_id_seq OWNER TO postgres;

--
-- Name: holidays_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.holidays_id_seq OWNED BY public.holidays.id;


--
-- Name: leave_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.leave_requests (
    id integer NOT NULL,
    employee_id integer NOT NULL,
    leave_type_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    days double precision NOT NULL,
    reason text,
    status character varying(16) NOT NULL,
    approved_by character varying(64),
    decided_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.leave_requests OWNER TO postgres;

--
-- Name: leave_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.leave_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.leave_requests_id_seq OWNER TO postgres;

--
-- Name: leave_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.leave_requests_id_seq OWNED BY public.leave_requests.id;


--
-- Name: leave_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.leave_types (
    id integer NOT NULL,
    code character varying(16) NOT NULL,
    name character varying(64) NOT NULL,
    is_paid boolean NOT NULL
);


ALTER TABLE public.leave_types OWNER TO postgres;

--
-- Name: leave_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.leave_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.leave_types_id_seq OWNER TO postgres;

--
-- Name: leave_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.leave_types_id_seq OWNED BY public.leave_types.id;


--
-- Name: offices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.offices (
    id integer NOT NULL,
    code character varying(32) NOT NULL,
    name character varying(128) NOT NULL
);


ALTER TABLE public.offices OWNER TO postgres;

--
-- Name: offices_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.offices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.offices_id_seq OWNER TO postgres;

--
-- Name: offices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.offices_id_seq OWNED BY public.offices.id;


--
-- Name: payroll_adjustments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payroll_adjustments (
    id integer NOT NULL,
    payroll_record_id integer NOT NULL,
    type character varying(16) NOT NULL,
    description character varying(255) NOT NULL,
    amount numeric(12,2) NOT NULL,
    created_by character varying(64),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.payroll_adjustments OWNER TO postgres;

--
-- Name: payroll_adjustments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payroll_adjustments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payroll_adjustments_id_seq OWNER TO postgres;

--
-- Name: payroll_adjustments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payroll_adjustments_id_seq OWNED BY public.payroll_adjustments.id;


--
-- Name: payroll_audit_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payroll_audit_log (
    id integer NOT NULL,
    payroll_period_id integer NOT NULL,
    payroll_record_id integer,
    action character varying(32) NOT NULL,
    actor character varying(64) NOT NULL,
    old_value json,
    new_value json,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.payroll_audit_log OWNER TO postgres;

--
-- Name: payroll_audit_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payroll_audit_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payroll_audit_log_id_seq OWNER TO postgres;

--
-- Name: payroll_audit_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payroll_audit_log_id_seq OWNED BY public.payroll_audit_log.id;


--
-- Name: payroll_periods; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payroll_periods (
    id integer NOT NULL,
    period_year integer NOT NULL,
    period_month integer NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    status character varying(16) NOT NULL,
    calculated_by character varying(64),
    calculated_at timestamp with time zone,
    approved_by character varying(64),
    approved_at timestamp with time zone,
    processed_by character varying(64),
    processed_at timestamp with time zone,
    paid_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.payroll_periods OWNER TO postgres;

--
-- Name: payroll_periods_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payroll_periods_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payroll_periods_id_seq OWNER TO postgres;

--
-- Name: payroll_periods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payroll_periods_id_seq OWNED BY public.payroll_periods.id;


--
-- Name: payroll_records; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payroll_records (
    id integer NOT NULL,
    payroll_period_id integer NOT NULL,
    employee_id integer NOT NULL,
    attendance_days double precision NOT NULL,
    present_days double precision NOT NULL,
    absent_days double precision NOT NULL,
    half_days double precision NOT NULL,
    leave_days double precision NOT NULL,
    holiday_days double precision NOT NULL,
    regular_hours double precision NOT NULL,
    overtime_hours double precision NOT NULL,
    late_count integer NOT NULL,
    early_checkout_count integer NOT NULL,
    missing_checkout_days integer NOT NULL,
    basic_salary numeric(12,2) NOT NULL,
    hra numeric(12,2) NOT NULL,
    allowances numeric(12,2) NOT NULL,
    bonus numeric(12,2) NOT NULL,
    overtime_pay numeric(12,2) NOT NULL,
    gross_salary numeric(12,2) NOT NULL,
    pf_deduction numeric(12,2) NOT NULL,
    esi_deduction numeric(12,2) NOT NULL,
    professional_tax numeric(12,2) NOT NULL,
    other_deductions numeric(12,2) NOT NULL,
    unpaid_leave_deduction numeric(12,2) NOT NULL,
    total_deductions numeric(12,2) NOT NULL,
    reimbursement numeric(12,2) NOT NULL,
    net_salary numeric(12,2) NOT NULL,
    breakdown json,
    status character varying(16) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.payroll_records OWNER TO postgres;

--
-- Name: payroll_records_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payroll_records_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payroll_records_id_seq OWNER TO postgres;

--
-- Name: payroll_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payroll_records_id_seq OWNED BY public.payroll_records.id;


--
-- Name: salary_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.salary_profiles (
    id integer NOT NULL,
    employee_id integer NOT NULL,
    basic_salary numeric(12,2) NOT NULL,
    hra numeric(12,2) NOT NULL,
    transport_allowance numeric(12,2) NOT NULL,
    medical_allowance numeric(12,2) NOT NULL,
    special_allowance numeric(12,2) NOT NULL,
    other_allowance numeric(12,2) NOT NULL,
    overtime_rate numeric(12,2) NOT NULL,
    working_hours_per_day double precision NOT NULL,
    working_days_per_month double precision NOT NULL,
    pf_enabled boolean NOT NULL,
    esi_enabled boolean NOT NULL,
    professional_tax numeric(12,2) NOT NULL,
    other_fixed_deduction numeric(12,2) NOT NULL,
    effective_from date NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.salary_profiles OWNER TO postgres;

--
-- Name: salary_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.salary_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.salary_profiles_id_seq OWNER TO postgres;

--
-- Name: salary_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.salary_profiles_id_seq OWNED BY public.salary_profiles.id;


--
-- Name: work_shifts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.work_shifts (
    id integer NOT NULL,
    name character varying(64) NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    break_minutes integer NOT NULL,
    grace_minutes integer NOT NULL,
    required_hours double precision NOT NULL,
    is_default boolean NOT NULL,
    is_active boolean NOT NULL
);


ALTER TABLE public.work_shifts OWNER TO postgres;

--
-- Name: work_shifts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.work_shifts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.work_shifts_id_seq OWNER TO postgres;

--
-- Name: work_shifts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.work_shifts_id_seq OWNED BY public.work_shifts.id;


--
-- Name: attendance id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance ALTER COLUMN id SET DEFAULT nextval('public.attendance_id_seq'::regclass);


--
-- Name: attendance_events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance_events ALTER COLUMN id SET DEFAULT nextval('public.attendance_events_id_seq'::regclass);


--
-- Name: employee_shifts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_shifts ALTER COLUMN id SET DEFAULT nextval('public.employee_shifts_id_seq'::regclass);


--
-- Name: employees id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees ALTER COLUMN id SET DEFAULT nextval('public.employees_id_seq'::regclass);


--
-- Name: face_embeddings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.face_embeddings ALTER COLUMN id SET DEFAULT nextval('public.face_embeddings_id_seq'::regclass);


--
-- Name: holidays id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.holidays ALTER COLUMN id SET DEFAULT nextval('public.holidays_id_seq'::regclass);


--
-- Name: leave_requests id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leave_requests ALTER COLUMN id SET DEFAULT nextval('public.leave_requests_id_seq'::regclass);


--
-- Name: leave_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leave_types ALTER COLUMN id SET DEFAULT nextval('public.leave_types_id_seq'::regclass);


--
-- Name: offices id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.offices ALTER COLUMN id SET DEFAULT nextval('public.offices_id_seq'::regclass);


--
-- Name: payroll_adjustments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll_adjustments ALTER COLUMN id SET DEFAULT nextval('public.payroll_adjustments_id_seq'::regclass);


--
-- Name: payroll_audit_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll_audit_log ALTER COLUMN id SET DEFAULT nextval('public.payroll_audit_log_id_seq'::regclass);


--
-- Name: payroll_periods id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll_periods ALTER COLUMN id SET DEFAULT nextval('public.payroll_periods_id_seq'::regclass);


--
-- Name: payroll_records id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll_records ALTER COLUMN id SET DEFAULT nextval('public.payroll_records_id_seq'::regclass);


--
-- Name: salary_profiles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary_profiles ALTER COLUMN id SET DEFAULT nextval('public.salary_profiles_id_seq'::regclass);


--
-- Name: work_shifts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_shifts ALTER COLUMN id SET DEFAULT nextval('public.work_shifts_id_seq'::regclass);


--
-- Data for Name: app_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.app_settings (key, value, updated_at) FROM stdin;
policy	{"week_off_days": [6], "full_day_min_hours": 6.0, "half_day_min_hours": 4.0, "overtime_threshold_minutes": 30, "early_checkout_threshold_minutes": 0, "missing_checkout_policy": "assume_required", "working_days_basis": "profile", "deduction_base": "fixed_gross", "rounding": "nearest_rupee", "overtime_multiplier": 1.5, "half_day_deduction_factor": 0.5, "deduct_absent_days": true, "pf_rate_percent": 12.0, "pf_wage_basis": "basic", "pf_wage_ceiling": 15000.0, "esi_rate_percent": 0.75, "esi_wage_basis": "gross", "esi_gross_ceiling": 21000.0}	2026-10-25 13:02:26.54703+05:30
\.


--
-- Data for Name: attendance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attendance (id, employee_id, office_id, attendance_date, check_in_time, check_out_time, check_in_similarity, check_out_similarity, status) FROM stdin;
1	1	1	2026-10-14	2026-10-14 19:47:25.300642+05:30	2026-10-14 18:05:00+05:30	0.7433	0.741	CHECKED_OUT
2	1	1	2026-10-01	2026-10-01 08:52:00+05:30	2026-10-01 18:08:00+05:30	0.745	0.738	CHECKED_OUT
3	2	1	2026-10-01	2026-10-01 08:52:00+05:30	2026-10-01 18:08:00+05:30	0.745	0.738	CHECKED_OUT
4	3	2	2026-10-01	2026-10-01 08:52:00+05:30	2026-10-01 18:08:00+05:30	0.745	0.738	CHECKED_OUT
5	4	2	2026-10-01	2026-10-01 08:52:00+05:30	2026-10-01 18:08:00+05:30	0.745	0.738	CHECKED_OUT
6	5	1	2026-10-01	2026-10-01 08:52:00+05:30	2026-10-01 18:08:00+05:30	0.745	0.738	CHECKED_OUT
7	1	1	2026-10-03	2026-10-03 09:25:00+05:30	2026-10-03 18:15:00+05:30	0.745	0.738	CHECKED_OUT
8	2	1	2026-10-03	2026-10-03 09:25:00+05:30	2026-10-03 18:15:00+05:30	0.745	0.738	CHECKED_OUT
9	3	2	2026-10-03	2026-10-03 09:25:00+05:30	2026-10-03 18:15:00+05:30	0.745	0.738	CHECKED_OUT
10	4	2	2026-10-03	2026-10-03 09:25:00+05:30	2026-10-03 18:15:00+05:30	0.745	0.738	CHECKED_OUT
11	5	1	2026-10-03	2026-10-03 09:25:00+05:30	2026-10-03 18:15:00+05:30	0.745	0.738	CHECKED_OUT
12	1	1	2026-10-05	2026-10-05 08:55:00+05:30	2026-10-05 19:45:00+05:30	0.745	0.738	CHECKED_OUT
13	2	1	2026-10-05	2026-10-05 08:55:00+05:30	2026-10-05 19:45:00+05:30	0.745	0.738	CHECKED_OUT
14	3	2	2026-10-05	2026-10-05 08:55:00+05:30	2026-10-05 19:45:00+05:30	0.745	0.738	CHECKED_OUT
15	4	2	2026-10-05	2026-10-05 08:55:00+05:30	2026-10-05 19:45:00+05:30	0.745	0.738	CHECKED_OUT
16	5	1	2026-10-05	2026-10-05 08:55:00+05:30	2026-10-05 19:45:00+05:30	0.745	0.738	CHECKED_OUT
17	1	1	2026-10-06	2026-10-06 08:52:00+05:30	2026-10-06 18:08:00+05:30	0.745	0.738	CHECKED_OUT
18	2	1	2026-10-06	2026-10-06 08:52:00+05:30	2026-10-06 18:08:00+05:30	0.745	0.738	CHECKED_OUT
19	3	2	2026-10-06	2026-10-06 08:52:00+05:30	2026-10-06 18:08:00+05:30	0.745	0.738	CHECKED_OUT
20	4	2	2026-10-06	2026-10-06 08:52:00+05:30	2026-10-06 18:08:00+05:30	0.745	0.738	CHECKED_OUT
21	5	1	2026-10-06	2026-10-06 08:52:00+05:30	2026-10-06 18:08:00+05:30	0.745	0.738	CHECKED_OUT
22	1	1	2026-10-07	2026-10-07 08:52:00+05:30	2026-10-07 18:08:00+05:30	0.745	0.738	CHECKED_OUT
23	2	1	2026-10-07	2026-10-07 08:52:00+05:30	2026-10-07 18:08:00+05:30	0.745	0.738	CHECKED_OUT
24	3	2	2026-10-07	2026-10-07 08:52:00+05:30	2026-10-07 18:08:00+05:30	0.745	0.738	CHECKED_OUT
25	4	2	2026-10-07	2026-10-07 08:52:00+05:30	2026-10-07 18:08:00+05:30	0.745	0.738	CHECKED_OUT
26	5	1	2026-10-07	2026-10-07 08:52:00+05:30	2026-10-07 18:08:00+05:30	0.745	0.738	CHECKED_OUT
27	1	1	2026-10-08	2026-10-08 08:52:00+05:30	2026-10-08 18:08:00+05:30	0.745	0.738	CHECKED_OUT
28	2	1	2026-10-08	2026-10-08 08:52:00+05:30	2026-10-08 18:08:00+05:30	0.745	0.738	CHECKED_OUT
29	3	2	2026-10-08	2026-10-08 08:52:00+05:30	2026-10-08 18:08:00+05:30	0.745	0.738	CHECKED_OUT
30	4	2	2026-10-08	2026-10-08 08:52:00+05:30	2026-10-08 18:08:00+05:30	0.745	0.738	CHECKED_OUT
31	5	1	2026-10-08	2026-10-08 08:52:00+05:30	2026-10-08 18:08:00+05:30	0.745	0.738	CHECKED_OUT
32	1	1	2026-10-09	2026-10-09 08:52:00+05:30	2026-10-09 18:08:00+05:30	0.745	0.738	CHECKED_OUT
33	2	1	2026-10-09	2026-10-09 08:52:00+05:30	2026-10-09 18:08:00+05:30	0.745	0.738	CHECKED_OUT
34	3	2	2026-10-09	2026-10-09 08:52:00+05:30	2026-10-09 18:08:00+05:30	0.745	0.738	CHECKED_OUT
35	4	2	2026-10-09	2026-10-09 08:52:00+05:30	2026-10-09 18:08:00+05:30	0.745	0.738	CHECKED_OUT
36	5	1	2026-10-09	2026-10-09 08:52:00+05:30	2026-10-09 18:08:00+05:30	0.745	0.738	CHECKED_OUT
37	1	1	2026-10-10	2026-10-10 09:25:00+05:30	2026-10-10 18:15:00+05:30	0.745	0.738	CHECKED_OUT
38	2	1	2026-10-10	2026-10-10 09:25:00+05:30	2026-10-10 18:15:00+05:30	0.745	0.738	CHECKED_OUT
39	3	2	2026-10-10	2026-10-10 09:25:00+05:30	2026-10-10 18:15:00+05:30	0.745	0.738	CHECKED_OUT
40	4	2	2026-10-10	2026-10-10 09:25:00+05:30	2026-10-10 18:15:00+05:30	0.745	0.738	CHECKED_OUT
41	5	1	2026-10-10	2026-10-10 09:25:00+05:30	2026-10-10 18:15:00+05:30	0.745	0.738	CHECKED_OUT
42	1	1	2026-10-12	2026-10-12 08:55:00+05:30	2026-10-12 19:45:00+05:30	0.745	0.738	CHECKED_OUT
43	2	1	2026-10-12	2026-10-12 08:55:00+05:30	2026-10-12 19:45:00+05:30	0.745	0.738	CHECKED_OUT
44	3	2	2026-10-12	2026-10-12 08:55:00+05:30	2026-10-12 19:45:00+05:30	0.745	0.738	CHECKED_OUT
45	4	2	2026-10-12	2026-10-12 08:55:00+05:30	2026-10-12 19:45:00+05:30	0.745	0.738	CHECKED_OUT
46	5	1	2026-10-12	2026-10-12 08:55:00+05:30	2026-10-12 19:45:00+05:30	0.745	0.738	CHECKED_OUT
47	1	1	2026-10-13	2026-10-13 08:52:00+05:30	2026-10-13 18:08:00+05:30	0.745	0.738	CHECKED_OUT
48	2	1	2026-10-13	2026-10-13 08:52:00+05:30	2026-10-13 18:08:00+05:30	0.745	0.738	CHECKED_OUT
49	3	2	2026-10-13	2026-10-13 08:52:00+05:30	2026-10-13 18:08:00+05:30	0.745	0.738	CHECKED_OUT
50	4	2	2026-10-13	2026-10-13 08:52:00+05:30	2026-10-13 18:08:00+05:30	0.745	0.738	CHECKED_OUT
51	5	1	2026-10-13	2026-10-13 08:52:00+05:30	2026-10-13 18:08:00+05:30	0.745	0.738	CHECKED_OUT
52	2	1	2026-10-14	2026-10-14 08:52:00+05:30	2026-10-14 18:08:00+05:30	0.745	0.738	CHECKED_OUT
53	3	2	2026-10-14	2026-10-14 08:52:00+05:30	2026-10-14 18:08:00+05:30	0.745	0.738	CHECKED_OUT
54	4	2	2026-10-14	2026-10-14 08:52:00+05:30	2026-10-14 18:08:00+05:30	0.745	0.738	CHECKED_OUT
55	5	1	2026-10-14	2026-10-14 08:52:00+05:30	2026-10-14 18:08:00+05:30	0.745	0.738	CHECKED_OUT
56	1	1	2026-10-15	2026-10-15 08:52:00+05:30	2026-10-15 18:08:00+05:30	0.745	0.738	CHECKED_OUT
57	3	2	2026-10-15	2026-10-15 08:52:00+05:30	2026-10-15 18:08:00+05:30	0.745	0.738	CHECKED_OUT
58	4	2	2026-10-15	2026-10-15 08:52:00+05:30	2026-10-15 18:08:00+05:30	0.745	0.738	CHECKED_OUT
59	5	1	2026-10-15	2026-10-15 08:52:00+05:30	2026-10-15 18:08:00+05:30	0.745	0.738	CHECKED_OUT
60	1	1	2026-10-16	2026-10-16 08:52:00+05:30	2026-10-16 18:08:00+05:30	0.745	0.738	CHECKED_OUT
61	2	1	2026-10-16	2026-10-16 08:52:00+05:30	2026-10-16 18:08:00+05:30	0.745	0.738	CHECKED_OUT
62	3	2	2026-10-16	2026-10-16 08:52:00+05:30	2026-10-16 18:08:00+05:30	0.745	0.738	CHECKED_OUT
63	4	2	2026-10-16	2026-10-16 08:52:00+05:30	2026-10-16 18:08:00+05:30	0.745	0.738	CHECKED_OUT
64	5	1	2026-10-16	2026-10-16 08:52:00+05:30	2026-10-16 18:08:00+05:30	0.745	0.738	CHECKED_OUT
65	1	1	2026-10-17	2026-10-17 09:25:00+05:30	2026-10-17 18:15:00+05:30	0.745	0.738	CHECKED_OUT
66	2	1	2026-10-17	2026-10-17 09:25:00+05:30	2026-10-17 18:15:00+05:30	0.745	0.738	CHECKED_OUT
67	3	2	2026-10-17	2026-10-17 09:25:00+05:30	2026-10-17 18:15:00+05:30	0.745	0.738	CHECKED_OUT
68	4	2	2026-10-17	2026-10-17 09:25:00+05:30	2026-10-17 18:15:00+05:30	0.745	0.738	CHECKED_OUT
69	5	1	2026-10-17	2026-10-17 09:25:00+05:30	2026-10-17 18:15:00+05:30	0.745	0.738	CHECKED_OUT
70	1	1	2026-10-19	2026-10-19 08:55:00+05:30	2026-10-19 19:45:00+05:30	0.745	0.738	CHECKED_OUT
71	2	1	2026-10-19	2026-10-19 08:55:00+05:30	2026-10-19 19:45:00+05:30	0.745	0.738	CHECKED_OUT
72	3	2	2026-10-19	2026-10-19 08:55:00+05:30	2026-10-19 19:45:00+05:30	0.745	0.738	CHECKED_OUT
73	4	2	2026-10-19	2026-10-19 08:55:00+05:30	2026-10-19 19:45:00+05:30	0.745	0.738	CHECKED_OUT
74	5	1	2026-10-19	2026-10-19 08:55:00+05:30	2026-10-19 19:45:00+05:30	0.745	0.738	CHECKED_OUT
75	1	1	2026-10-21	2026-10-21 08:52:00+05:30	2026-10-21 18:08:00+05:30	0.745	0.738	CHECKED_OUT
76	2	1	2026-10-21	2026-10-21 08:52:00+05:30	2026-10-21 18:08:00+05:30	0.745	0.738	CHECKED_OUT
77	3	2	2026-10-21	2026-10-21 08:52:00+05:30	2026-10-21 18:08:00+05:30	0.745	0.738	CHECKED_OUT
78	4	2	2026-10-21	2026-10-21 08:52:00+05:30	2026-10-21 18:08:00+05:30	0.745	0.738	CHECKED_OUT
79	5	1	2026-10-21	2026-10-21 08:52:00+05:30	2026-10-21 18:08:00+05:30	0.745	0.738	CHECKED_OUT
80	1	1	2026-10-22	2026-10-22 08:52:00+05:30	2026-10-22 18:08:00+05:30	0.745	0.738	CHECKED_OUT
81	2	1	2026-10-22	2026-10-22 08:52:00+05:30	2026-10-22 18:08:00+05:30	0.745	0.738	CHECKED_OUT
82	3	2	2026-10-22	2026-10-22 08:52:00+05:30	2026-10-22 18:08:00+05:30	0.745	0.738	CHECKED_OUT
83	4	2	2026-10-22	2026-10-22 08:52:00+05:30	2026-10-22 18:08:00+05:30	0.745	0.738	CHECKED_OUT
84	5	1	2026-10-22	2026-10-22 08:52:00+05:30	2026-10-22 18:08:00+05:30	0.745	0.738	CHECKED_OUT
85	1	1	2026-10-23	2026-10-23 08:52:00+05:30	2026-10-23 18:08:00+05:30	0.745	0.738	CHECKED_OUT
86	2	1	2026-10-23	2026-10-23 08:52:00+05:30	2026-10-23 18:08:00+05:30	0.745	0.738	CHECKED_OUT
87	3	2	2026-10-23	2026-10-23 08:52:00+05:30	2026-10-23 18:08:00+05:30	0.745	0.738	CHECKED_OUT
88	4	2	2026-10-23	2026-10-23 08:52:00+05:30	2026-10-23 18:08:00+05:30	0.745	0.738	CHECKED_OUT
89	5	1	2026-10-23	2026-10-23 08:52:00+05:30	2026-10-23 18:08:00+05:30	0.745	0.738	CHECKED_OUT
90	1	1	2026-10-24	2026-10-24 09:25:00+05:30	2026-10-24 18:15:00+05:30	0.745	0.738	CHECKED_OUT
91	2	1	2026-10-24	2026-10-24 09:25:00+05:30	2026-10-24 18:15:00+05:30	0.745	0.738	CHECKED_OUT
92	3	2	2026-10-24	2026-10-24 09:25:00+05:30	2026-10-24 18:15:00+05:30	0.745	0.738	CHECKED_OUT
93	4	2	2026-10-24	2026-10-24 09:25:00+05:30	2026-10-24 18:15:00+05:30	0.745	0.738	CHECKED_OUT
94	5	1	2026-10-24	2026-10-24 09:25:00+05:30	2026-10-24 18:15:00+05:30	0.745	0.738	CHECKED_OUT
95	1	1	2026-09-01	2026-09-01 08:50:00+05:30	2026-09-01 18:05:00+05:30	0.75	0.742	CHECKED_OUT
96	2	1	2026-09-01	2026-09-01 08:50:00+05:30	2026-09-01 18:05:00+05:30	0.75	0.742	CHECKED_OUT
97	3	2	2026-09-01	2026-09-01 08:50:00+05:30	2026-09-01 18:05:00+05:30	0.75	0.742	CHECKED_OUT
98	4	2	2026-09-01	2026-09-01 08:50:00+05:30	2026-09-01 18:05:00+05:30	0.75	0.742	CHECKED_OUT
99	5	1	2026-09-01	2026-09-01 08:50:00+05:30	2026-09-01 18:05:00+05:30	0.75	0.742	CHECKED_OUT
100	1	1	2026-09-02	2026-09-02 09:20:00+05:30	2026-09-02 18:10:00+05:30	0.75	0.742	CHECKED_OUT
101	2	1	2026-09-02	2026-09-02 09:20:00+05:30	2026-09-02 18:10:00+05:30	0.75	0.742	CHECKED_OUT
102	3	2	2026-09-02	2026-09-02 09:20:00+05:30	2026-09-02 18:10:00+05:30	0.75	0.742	CHECKED_OUT
103	4	2	2026-09-02	2026-09-02 09:20:00+05:30	2026-09-02 18:10:00+05:30	0.75	0.742	CHECKED_OUT
104	5	1	2026-09-02	2026-09-02 09:20:00+05:30	2026-09-02 18:10:00+05:30	0.75	0.742	CHECKED_OUT
105	1	1	2026-09-03	2026-09-03 08:50:00+05:30	2026-09-03 18:05:00+05:30	0.75	0.742	CHECKED_OUT
106	2	1	2026-09-03	2026-09-03 08:50:00+05:30	2026-09-03 18:05:00+05:30	0.75	0.742	CHECKED_OUT
107	3	2	2026-09-03	2026-09-03 08:50:00+05:30	2026-09-03 18:05:00+05:30	0.75	0.742	CHECKED_OUT
108	4	2	2026-09-03	2026-09-03 08:50:00+05:30	2026-09-03 18:05:00+05:30	0.75	0.742	CHECKED_OUT
109	5	1	2026-09-03	2026-09-03 08:50:00+05:30	2026-09-03 18:05:00+05:30	0.75	0.742	CHECKED_OUT
110	1	1	2026-09-04	2026-09-04 08:55:00+05:30	2026-09-04 19:30:00+05:30	0.75	0.742	CHECKED_OUT
111	2	1	2026-09-04	2026-09-04 08:55:00+05:30	2026-09-04 19:30:00+05:30	0.75	0.742	CHECKED_OUT
112	3	2	2026-09-04	2026-09-04 08:55:00+05:30	2026-09-04 19:30:00+05:30	0.75	0.742	CHECKED_OUT
113	4	2	2026-09-04	2026-09-04 08:55:00+05:30	2026-09-04 19:30:00+05:30	0.75	0.742	CHECKED_OUT
114	5	1	2026-09-04	2026-09-04 08:55:00+05:30	2026-09-04 19:30:00+05:30	0.75	0.742	CHECKED_OUT
115	1	1	2026-09-05	2026-09-05 08:50:00+05:30	2026-09-05 18:05:00+05:30	0.75	0.742	CHECKED_OUT
116	2	1	2026-09-05	2026-09-05 08:50:00+05:30	2026-09-05 18:05:00+05:30	0.75	0.742	CHECKED_OUT
117	3	2	2026-09-05	2026-09-05 08:50:00+05:30	2026-09-05 18:05:00+05:30	0.75	0.742	CHECKED_OUT
118	4	2	2026-09-05	2026-09-05 08:50:00+05:30	2026-09-05 18:05:00+05:30	0.75	0.742	CHECKED_OUT
119	5	1	2026-09-05	2026-09-05 08:50:00+05:30	2026-09-05 18:05:00+05:30	0.75	0.742	CHECKED_OUT
120	1	1	2026-09-07	2026-09-07 08:50:00+05:30	2026-09-07 18:05:00+05:30	0.75	0.742	CHECKED_OUT
121	2	1	2026-09-07	2026-09-07 08:50:00+05:30	2026-09-07 18:05:00+05:30	0.75	0.742	CHECKED_OUT
122	3	2	2026-09-07	2026-09-07 08:50:00+05:30	2026-09-07 18:05:00+05:30	0.75	0.742	CHECKED_OUT
123	4	2	2026-09-07	2026-09-07 08:50:00+05:30	2026-09-07 18:05:00+05:30	0.75	0.742	CHECKED_OUT
124	5	1	2026-09-07	2026-09-07 08:50:00+05:30	2026-09-07 18:05:00+05:30	0.75	0.742	CHECKED_OUT
125	1	1	2026-09-08	2026-09-08 09:20:00+05:30	2026-09-08 18:10:00+05:30	0.75	0.742	CHECKED_OUT
126	2	1	2026-09-08	2026-09-08 09:20:00+05:30	2026-09-08 18:10:00+05:30	0.75	0.742	CHECKED_OUT
127	3	2	2026-09-08	2026-09-08 09:20:00+05:30	2026-09-08 18:10:00+05:30	0.75	0.742	CHECKED_OUT
128	4	2	2026-09-08	2026-09-08 09:20:00+05:30	2026-09-08 18:10:00+05:30	0.75	0.742	CHECKED_OUT
129	5	1	2026-09-08	2026-09-08 09:20:00+05:30	2026-09-08 18:10:00+05:30	0.75	0.742	CHECKED_OUT
130	1	1	2026-09-09	2026-09-09 08:50:00+05:30	2026-09-09 18:05:00+05:30	0.75	0.742	CHECKED_OUT
131	2	1	2026-09-09	2026-09-09 08:50:00+05:30	2026-09-09 18:05:00+05:30	0.75	0.742	CHECKED_OUT
132	3	2	2026-09-09	2026-09-09 08:50:00+05:30	2026-09-09 18:05:00+05:30	0.75	0.742	CHECKED_OUT
133	4	2	2026-09-09	2026-09-09 08:50:00+05:30	2026-09-09 18:05:00+05:30	0.75	0.742	CHECKED_OUT
134	5	1	2026-09-09	2026-09-09 08:50:00+05:30	2026-09-09 18:05:00+05:30	0.75	0.742	CHECKED_OUT
135	1	1	2026-09-10	2026-09-10 08:55:00+05:30	2026-09-10 19:30:00+05:30	0.75	0.742	CHECKED_OUT
136	2	1	2026-09-10	2026-09-10 08:55:00+05:30	2026-09-10 19:30:00+05:30	0.75	0.742	CHECKED_OUT
137	3	2	2026-09-10	2026-09-10 08:55:00+05:30	2026-09-10 19:30:00+05:30	0.75	0.742	CHECKED_OUT
138	4	2	2026-09-10	2026-09-10 08:55:00+05:30	2026-09-10 19:30:00+05:30	0.75	0.742	CHECKED_OUT
139	5	1	2026-09-10	2026-09-10 08:55:00+05:30	2026-09-10 19:30:00+05:30	0.75	0.742	CHECKED_OUT
140	1	1	2026-09-11	2026-09-11 08:50:00+05:30	2026-09-11 18:05:00+05:30	0.75	0.742	CHECKED_OUT
141	2	1	2026-09-11	2026-09-11 08:50:00+05:30	2026-09-11 18:05:00+05:30	0.75	0.742	CHECKED_OUT
142	3	2	2026-09-11	2026-09-11 08:50:00+05:30	2026-09-11 18:05:00+05:30	0.75	0.742	CHECKED_OUT
143	4	2	2026-09-11	2026-09-11 08:50:00+05:30	2026-09-11 18:05:00+05:30	0.75	0.742	CHECKED_OUT
144	5	1	2026-09-11	2026-09-11 08:50:00+05:30	2026-09-11 18:05:00+05:30	0.75	0.742	CHECKED_OUT
145	1	1	2026-09-12	2026-09-12 08:50:00+05:30	2026-09-12 18:05:00+05:30	0.75	0.742	CHECKED_OUT
146	2	1	2026-09-12	2026-09-12 08:50:00+05:30	2026-09-12 18:05:00+05:30	0.75	0.742	CHECKED_OUT
147	3	2	2026-09-12	2026-09-12 08:50:00+05:30	2026-09-12 18:05:00+05:30	0.75	0.742	CHECKED_OUT
148	4	2	2026-09-12	2026-09-12 08:50:00+05:30	2026-09-12 18:05:00+05:30	0.75	0.742	CHECKED_OUT
149	5	1	2026-09-12	2026-09-12 08:50:00+05:30	2026-09-12 18:05:00+05:30	0.75	0.742	CHECKED_OUT
150	1	1	2026-09-14	2026-09-14 09:20:00+05:30	2026-09-14 18:10:00+05:30	0.75	0.742	CHECKED_OUT
151	2	1	2026-09-14	2026-09-14 09:20:00+05:30	2026-09-14 18:10:00+05:30	0.75	0.742	CHECKED_OUT
152	3	2	2026-09-14	2026-09-14 09:20:00+05:30	2026-09-14 18:10:00+05:30	0.75	0.742	CHECKED_OUT
153	4	2	2026-09-14	2026-09-14 09:20:00+05:30	2026-09-14 18:10:00+05:30	0.75	0.742	CHECKED_OUT
154	5	1	2026-09-14	2026-09-14 09:20:00+05:30	2026-09-14 18:10:00+05:30	0.75	0.742	CHECKED_OUT
155	1	1	2026-09-15	2026-09-15 08:50:00+05:30	2026-09-15 18:05:00+05:30	0.75	0.742	CHECKED_OUT
156	2	1	2026-09-15	2026-09-15 08:50:00+05:30	2026-09-15 18:05:00+05:30	0.75	0.742	CHECKED_OUT
157	3	2	2026-09-15	2026-09-15 08:50:00+05:30	2026-09-15 18:05:00+05:30	0.75	0.742	CHECKED_OUT
158	4	2	2026-09-15	2026-09-15 08:50:00+05:30	2026-09-15 18:05:00+05:30	0.75	0.742	CHECKED_OUT
159	5	1	2026-09-15	2026-09-15 08:50:00+05:30	2026-09-15 18:05:00+05:30	0.75	0.742	CHECKED_OUT
160	1	1	2026-09-16	2026-09-16 08:55:00+05:30	2026-09-16 19:30:00+05:30	0.75	0.742	CHECKED_OUT
161	2	1	2026-09-16	2026-09-16 08:55:00+05:30	2026-09-16 19:30:00+05:30	0.75	0.742	CHECKED_OUT
162	3	2	2026-09-16	2026-09-16 08:55:00+05:30	2026-09-16 19:30:00+05:30	0.75	0.742	CHECKED_OUT
163	4	2	2026-09-16	2026-09-16 08:55:00+05:30	2026-09-16 19:30:00+05:30	0.75	0.742	CHECKED_OUT
164	5	1	2026-09-16	2026-09-16 08:55:00+05:30	2026-09-16 19:30:00+05:30	0.75	0.742	CHECKED_OUT
165	1	1	2026-09-17	2026-09-17 08:50:00+05:30	2026-09-17 18:05:00+05:30	0.75	0.742	CHECKED_OUT
166	2	1	2026-09-17	2026-09-17 08:50:00+05:30	2026-09-17 18:05:00+05:30	0.75	0.742	CHECKED_OUT
167	3	2	2026-09-17	2026-09-17 08:50:00+05:30	2026-09-17 18:05:00+05:30	0.75	0.742	CHECKED_OUT
168	4	2	2026-09-17	2026-09-17 08:50:00+05:30	2026-09-17 18:05:00+05:30	0.75	0.742	CHECKED_OUT
169	5	1	2026-09-17	2026-09-17 08:50:00+05:30	2026-09-17 18:05:00+05:30	0.75	0.742	CHECKED_OUT
170	1	1	2026-09-18	2026-09-18 08:50:00+05:30	2026-09-18 18:05:00+05:30	0.75	0.742	CHECKED_OUT
171	2	1	2026-09-18	2026-09-18 08:50:00+05:30	2026-09-18 18:05:00+05:30	0.75	0.742	CHECKED_OUT
172	3	2	2026-09-18	2026-09-18 08:50:00+05:30	2026-09-18 18:05:00+05:30	0.75	0.742	CHECKED_OUT
173	4	2	2026-09-18	2026-09-18 08:50:00+05:30	2026-09-18 18:05:00+05:30	0.75	0.742	CHECKED_OUT
174	5	1	2026-09-18	2026-09-18 08:50:00+05:30	2026-09-18 18:05:00+05:30	0.75	0.742	CHECKED_OUT
175	1	1	2026-09-19	2026-09-19 08:50:00+05:30	2026-09-19 18:05:00+05:30	0.75	0.742	CHECKED_OUT
176	2	1	2026-09-19	2026-09-19 08:50:00+05:30	2026-09-19 18:05:00+05:30	0.75	0.742	CHECKED_OUT
177	3	2	2026-09-19	2026-09-19 08:50:00+05:30	2026-09-19 18:05:00+05:30	0.75	0.742	CHECKED_OUT
178	4	2	2026-09-19	2026-09-19 08:50:00+05:30	2026-09-19 18:05:00+05:30	0.75	0.742	CHECKED_OUT
179	5	1	2026-09-19	2026-09-19 08:50:00+05:30	2026-09-19 18:05:00+05:30	0.75	0.742	CHECKED_OUT
180	1	1	2026-09-21	2026-09-21 08:50:00+05:30	2026-09-21 18:05:00+05:30	0.75	0.742	CHECKED_OUT
181	2	1	2026-09-21	2026-09-21 08:50:00+05:30	2026-09-21 18:05:00+05:30	0.75	0.742	CHECKED_OUT
182	3	2	2026-09-21	2026-09-21 08:50:00+05:30	2026-09-21 18:05:00+05:30	0.75	0.742	CHECKED_OUT
183	4	2	2026-09-21	2026-09-21 08:50:00+05:30	2026-09-21 18:05:00+05:30	0.75	0.742	CHECKED_OUT
184	5	1	2026-09-21	2026-09-21 08:50:00+05:30	2026-09-21 18:05:00+05:30	0.75	0.742	CHECKED_OUT
185	1	1	2026-09-22	2026-09-22 08:55:00+05:30	2026-09-22 19:30:00+05:30	0.75	0.742	CHECKED_OUT
186	2	1	2026-09-22	2026-09-22 08:55:00+05:30	2026-09-22 19:30:00+05:30	0.75	0.742	CHECKED_OUT
187	3	2	2026-09-22	2026-09-22 08:55:00+05:30	2026-09-22 19:30:00+05:30	0.75	0.742	CHECKED_OUT
188	4	2	2026-09-22	2026-09-22 08:55:00+05:30	2026-09-22 19:30:00+05:30	0.75	0.742	CHECKED_OUT
189	5	1	2026-09-22	2026-09-22 08:55:00+05:30	2026-09-22 19:30:00+05:30	0.75	0.742	CHECKED_OUT
190	1	1	2026-09-23	2026-09-23 08:50:00+05:30	2026-09-23 18:05:00+05:30	0.75	0.742	CHECKED_OUT
191	2	1	2026-09-23	2026-09-23 08:50:00+05:30	2026-09-23 18:05:00+05:30	0.75	0.742	CHECKED_OUT
192	3	2	2026-09-23	2026-09-23 08:50:00+05:30	2026-09-23 18:05:00+05:30	0.75	0.742	CHECKED_OUT
193	4	2	2026-09-23	2026-09-23 08:50:00+05:30	2026-09-23 18:05:00+05:30	0.75	0.742	CHECKED_OUT
194	5	1	2026-09-23	2026-09-23 08:50:00+05:30	2026-09-23 18:05:00+05:30	0.75	0.742	CHECKED_OUT
195	1	1	2026-09-24	2026-09-24 08:50:00+05:30	2026-09-24 18:05:00+05:30	0.75	0.742	CHECKED_OUT
196	2	1	2026-09-24	2026-09-24 08:50:00+05:30	2026-09-24 18:05:00+05:30	0.75	0.742	CHECKED_OUT
197	3	2	2026-09-24	2026-09-24 08:50:00+05:30	2026-09-24 18:05:00+05:30	0.75	0.742	CHECKED_OUT
198	4	2	2026-09-24	2026-09-24 08:50:00+05:30	2026-09-24 18:05:00+05:30	0.75	0.742	CHECKED_OUT
199	5	1	2026-09-24	2026-09-24 08:50:00+05:30	2026-09-24 18:05:00+05:30	0.75	0.742	CHECKED_OUT
200	1	1	2026-09-25	2026-09-25 08:50:00+05:30	2026-09-25 18:05:00+05:30	0.75	0.742	CHECKED_OUT
201	2	1	2026-09-25	2026-09-25 08:50:00+05:30	2026-09-25 18:05:00+05:30	0.75	0.742	CHECKED_OUT
202	3	2	2026-09-25	2026-09-25 08:50:00+05:30	2026-09-25 18:05:00+05:30	0.75	0.742	CHECKED_OUT
203	4	2	2026-09-25	2026-09-25 08:50:00+05:30	2026-09-25 18:05:00+05:30	0.75	0.742	CHECKED_OUT
204	5	1	2026-09-25	2026-09-25 08:50:00+05:30	2026-09-25 18:05:00+05:30	0.75	0.742	CHECKED_OUT
205	1	1	2026-09-26	2026-09-26 09:20:00+05:30	2026-09-26 18:10:00+05:30	0.75	0.742	CHECKED_OUT
206	2	1	2026-09-26	2026-09-26 09:20:00+05:30	2026-09-26 18:10:00+05:30	0.75	0.742	CHECKED_OUT
207	3	2	2026-09-26	2026-09-26 09:20:00+05:30	2026-09-26 18:10:00+05:30	0.75	0.742	CHECKED_OUT
208	4	2	2026-09-26	2026-09-26 09:20:00+05:30	2026-09-26 18:10:00+05:30	0.75	0.742	CHECKED_OUT
209	5	1	2026-09-26	2026-09-26 09:20:00+05:30	2026-09-26 18:10:00+05:30	0.75	0.742	CHECKED_OUT
210	1	1	2026-09-28	2026-09-28 08:55:00+05:30	2026-09-28 19:30:00+05:30	0.75	0.742	CHECKED_OUT
211	2	1	2026-09-28	2026-09-28 08:55:00+05:30	2026-09-28 19:30:00+05:30	0.75	0.742	CHECKED_OUT
212	3	2	2026-09-28	2026-09-28 08:55:00+05:30	2026-09-28 19:30:00+05:30	0.75	0.742	CHECKED_OUT
213	4	2	2026-09-28	2026-09-28 08:55:00+05:30	2026-09-28 19:30:00+05:30	0.75	0.742	CHECKED_OUT
214	5	1	2026-09-28	2026-09-28 08:55:00+05:30	2026-09-28 19:30:00+05:30	0.75	0.742	CHECKED_OUT
215	1	1	2026-09-29	2026-09-29 08:50:00+05:30	2026-09-29 18:05:00+05:30	0.75	0.742	CHECKED_OUT
216	2	1	2026-09-29	2026-09-29 08:50:00+05:30	2026-09-29 18:05:00+05:30	0.75	0.742	CHECKED_OUT
217	3	2	2026-09-29	2026-09-29 08:50:00+05:30	2026-09-29 18:05:00+05:30	0.75	0.742	CHECKED_OUT
218	4	2	2026-09-29	2026-09-29 08:50:00+05:30	2026-09-29 18:05:00+05:30	0.75	0.742	CHECKED_OUT
219	5	1	2026-09-29	2026-09-29 08:50:00+05:30	2026-09-29 18:05:00+05:30	0.75	0.742	CHECKED_OUT
220	1	1	2026-09-30	2026-09-30 08:50:00+05:30	2026-09-30 18:05:00+05:30	0.75	0.742	CHECKED_OUT
221	2	1	2026-09-30	2026-09-30 08:50:00+05:30	2026-09-30 18:05:00+05:30	0.75	0.742	CHECKED_OUT
222	3	2	2026-09-30	2026-09-30 08:50:00+05:30	2026-09-30 18:05:00+05:30	0.75	0.742	CHECKED_OUT
223	4	2	2026-09-30	2026-09-30 08:50:00+05:30	2026-09-30 18:05:00+05:30	0.75	0.742	CHECKED_OUT
224	5	1	2026-09-30	2026-09-30 08:50:00+05:30	2026-09-30 18:05:00+05:30	0.75	0.742	CHECKED_OUT
\.


--
-- Data for Name: attendance_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attendance_events (id, employee_id, office_id, event_type, similarity, details, created_at) FROM stdin;
1	\N	\N	UNKNOWN_FACE	0	{"reason": "gallery_empty", "candidate": null, "margin": 0.0}	2026-10-14 19:44:44.463618+05:30
2	\N	\N	UNKNOWN_FACE	0	{"reason": "gallery_empty", "candidate": null, "margin": 0.0}	2026-10-14 19:46:17.009806+05:30
3	1	1	ENROLLMENT_COMPLETED	\N	{"samples": 15}	2026-10-14 19:47:13.752275+05:30
4	1	1	CHECK_IN	0.7433	null	2026-10-14 19:47:25.299497+05:30
5	1	1	RECOGNITION	0.7433	null	2026-10-14 19:47:25.299497+05:30
6	1	1	RECOGNITION	0.636	null	2026-10-14 19:51:05.269141+05:30
7	1	1	RECOGNITION	0.7221	null	2026-10-14 19:52:20.726966+05:30
\.


--
-- Data for Name: employee_shifts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employee_shifts (id, employee_id, shift_id, effective_from, effective_to) FROM stdin;
1	1	1	2026-01-01	\N
2	2	1	2026-01-01	\N
3	3	1	2026-01-01	\N
4	4	1	2026-01-01	\N
5	5	2	2026-01-01	\N
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employees (id, employee_code, name, office_id, is_active, created_at, updated_at, department, designation, email, phone) FROM stdin;
1	1234	karthikeya	1	t	2026-10-14 19:45:55.089868+05:30	2026-10-25 13:02:26.260214+05:30	Engineering	Lead AI Architect	karthikeya@company.com	+91 9848012345
2	1001	Santhoshi Rayudu	1	t	2026-10-25 13:02:26.260214+05:30	2026-10-25 13:02:26.260214+05:30	AI Labs	Senior ML Engineer	santhoshi@company.com	+91 9440123456
3	1002	Arjun Verma	2	t	2026-10-25 13:02:26.260214+05:30	2026-10-25 13:02:26.260214+05:30	Product	Product Manager	arjun.v@company.com	+91 9885012345
4	1003	Priya Sharma	2	t	2026-10-25 13:02:26.260214+05:30	2026-10-25 13:02:26.260214+05:30	Human Resources	HR Operations Lead	priya.s@company.com	+91 9700012345
5	1004	Rahul Nair	1	t	2026-10-25 13:02:26.260214+05:30	2026-10-25 13:02:26.260214+05:30	Engineering	Senior DevOps Engineer	rahul.n@company.com	+91 9618012345
6	TEST99	Test User Updated	1	f	2026-10-25 13:13:30.852149+05:30	2026-10-25 13:13:30.889129+05:30	Quality Assurance	Lead QA Engineer	test.user@company.com	+91 9123456780
\.


--
-- Data for Name: face_embeddings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.face_embeddings (id, employee_id, embedding, model_name, blur_score, liveness_score, created_at) FROM stdin;
1	1	\\xa8e6a5bc2998abbd76c9c93cbfb1f63ddbc188bcd6ac21bbe4663dbd1616d3bdce4471bc91161e3ded2d333de2db2d3d4cf81abd852f49bc6e89bd3c895f27bdc700a73d1c1f42bdf639803dc40aac3c7be9c73c78e313bdd8961d3de1e3843d19b7d0bc7e2a0f3bbac62c3d7667b5bac8b459bdc3f4d8bc71bec5bd2505f6bcb1ec45bd083e18bda5f0aa3dc2ad9e3c140aaa3d57cf5abdf8794a3d5dd6703dcd9adb3c7bbb8bbd60318cbce31bf43bfcdb6f3df7b76abc6bcc983d58d6663b9b5f2c3d069e9a3b29f0423da0d862bc530a9a3c57cac13c526709bd73fc2d3cdb5b093d201f553d92c530bdd1d82c3dc708d5bda8d54b3c7f8f593b4805a6bd5ec7b0bd8797b7bd8d4f613d0cd4cb3c35b24b3b638e463b245e3cbd9f5880bc8420773d06c94cbd63b7d63abcf47bbc05e869bcbe0e72bcbd7390bd646e3cbd6797923c6fa2e33b5ff4efba7201973b13c13cbca1a627bbaa90023cada2f13c75c8b4bd0fc0c0bd56add0bd46ef4c3dad798c3d538ee8bbb2f05ebc2d82133c00f7523c360f6e3da540e1bc34bd503dfc8159bda2e9153dfec243bdcf36a5bdada9853d96f080bd1d6b9fbc3812b8bcd75203bd56ffb33c29cdd13b0e9795ba17276b3df1225e3dfc9229bd2eba4cbd3c86ff3bb35854bcba47e13c1a9e6dbb011a223c9ae3603c76fdc33d20f61dbd8f42a0bdf6cae43d85b59a3dcde683bc44f3203df0263fbd562951bd6b67553d8822fe3c75a69ebcb516483dc7055a3d814cb83d0fb1de3cb96fc43c6398d2bb1af517bdfd37013d0175973b94c2d83cfad9c33cce815cbdc6f18d3a127e06bdffca44bba9ee39bde649a63caa75793c11f683bcc81d663d4fe12dbd01da44bd16341fb9d39707bde12082bda99457bdd864b23c2411453da02042bde9f3b0bbec2a3f3c28f3dfbc1cbcdc3cb3b2823d3b6d96bd763b6dbcfe97c53cdfef24bc30381f3d8a6fb0bc3c4038bdd8c982bc21d47cbd8a55babb4cd80a3d918159bd9c15ef3bde82cb3bb170a33b254c2e3d3d7e8f3dd8724abcfcc35a3c98530d3de6ee093ded7cc23c2b7d1ebde50154bdaabb9b3da8537dbd7b66e1bc42b7e9bcf2a446bd0bf950bdbf80723d53e048bc154832bddbb694bd539b8c3c92bfa2bc42b1e63a89de31bd382f6fbd3502273db058c9bc0164da3c6be3683a14865abdc46ea73de21330bd37b090bc34ed273d0132d43d9122323c8cb0cfbd68020d3c31d2b6bb5a700cbd4fb1b5bca20016ba47b3a33d9724ae3b132c9cbd73244dbc68a78dbc4810043dff4208bdcb1b213df81e813c9fee3c3cd3907fbd4ac643bd1718213c98311a3b9ad8043c9b14bcbd7197afbc7f1b10bba14ebdbcaf16c9b9565785bd3beea4bc84b3843d5ec68fbccf9b0cbc75a65dbcad778dbceb859ebdbfaa16bd725358bce0101fbdd5b7093d7a85e4bc73b7643df31da03cf031fcbc2fa3593b9e249e3c7bb4c83c684592bdd5cf913d892f58bd237f683c474945bd7a10783cfe331dbd239646bdb8edc5bc8812183dd3e0bcbbdc19b0bdf0d8a43d8968c73ccbad363db20c06bd25f51abba3dc383dceaa653c75be3a3d9a3a0c3da4bb843b309314bc49bd573dfd7a003c98e46fbd3044afbdf76ef839a6edc63c6cec64bdea10043c4b52ec3c803313bd327d6f3dca5406bda410103c5aa58a3b73f025bde0db70bd3c5763bdbb5880bddca355bc7aaf2c3d01d18c3db724453d90ddf1bdc2612f3d192eb8b89bf518bb8c460c3c9eba57bc848d4abc18ee733c6ce1ccbb81a818bad766793d854317bccab28abda3ce34bd29634dbc173e083dab8d02bdce7632bcce674ebd0d4e15bde5a0e13dd5ef643ddfead2bd981f9cbd15deb73c39723fbdb82ea439523d6e3d6c4d333daed692bb7ed52e3cd7b351bdc25227bdf7c793bbcee531bdee64053d94b2c0bc5571833dc598f93c1c5fa73ca8381d3dc55c613bbcdc87bc0d8986bdd188d5bc6b6c9e3ccb38b6bd6c7882bcc17390bd1fffb1bd3e4d1e3de27e7fbc5bbea23d5e3beaba025699bd7eb69e3d5fa2e1bc8904243da13ee03c098082bc4edc39bd7707d0bbe89596bc1502ac3cdd6129bd5c1e49bcd15801bd32bd9dbd14c2553dc313d33cc5870c3d9bfc893d9d4dd0bb1e00e13af54b233ddfa82e3ce49253bcba58733b10d1503d0923f3bce29d5a3cf6d515bd1c115dbdb2eaae3d385b11bc214fa7bcfabbc53c091c803bf68618bc162e383d739a683d276c86bd5f4b213cc0697c3c86f1243cbe8f01bc9165cbbbaf1f14bd4bc859bc7e92003d433b063c0169d73cb6fd6abccab7593bb9bcaebc0a4913397d8b5d3d11635cbc9ed1c73bfc5ec3bc71dc56bcb068103ddee7203dbe8f1e3dc62d183cd499013d49592fbdffb5b9bda32db43c20a63abdf3ca923b34dc653d7215b6b82d5d3c3db24a1fbd2ce7a8bc8bff083d4bb0223c1f4446bd75810fbd00024b3d775595bd3cd1933c64317dbd40235b3c1d21d8bcb70daabd5a2909bd78afaf3c75299c3de80d4fbd5dbe4f3cb6eff13a5f22a3bd3bab053d7149143dd205bd3c7dbc4c3c6922d43c9554363d63e45c3dfe06803d31b73c3c1f9210bddb76f83c975639bc11f9343ce95f73ba4879953c5f7a73bcbef0d9baf4187c3d619db43c09862a3c436c08bdf8ec8cbb6f37c8bd5e15353c16f3603d535f0cbdd103793db3e48cbde4a0d73c989fa9bc786282bdb09a84bb761a863a7af9cc3cdbbcf6bcd49f873de7ba9cbdce8644bddecd5f3d22cb1e3c899ab7bc595ecf3ca6d9503cb4d7573d570688bc2b01383dee19133dfe63c13dd4d03d3c8b82943d222c32bc05d550bd55fb363d736a443dd370fabdc0e8813c063d17bd8b209bbd93876dbd1487f0bc	w600k_mbf	55.83	0.9162	2026-10-14 19:47:13.752275+05:30
2	1	\\x05e0593c220287bc6d8d2b3b3c33113dc0958fbcbe361ebd4bad69bd7630dfbdb78baebd14c498bd7564853c90a1353d0272d23b0f928b3ce559863d32216fbd3505ab3d3a56a1bc37b25e3dae0e81bcb472a73d862b20bd8a2b983d773e3a3d9fb368bbcac8903ce617fc3c0fc021bb308564bdf7ed02bddc8917baff2f82bcf612a6bc8daa4dbc4fc46b3d5c6fb5bc2383713deb34b0bd88b2b7ba0f07a53d758a173deb0a7abd25a849bdf8531e3dcc440e3dd8448e3cd1ea853dc61f2a3ba3ae71bc8824513df24468bbb3511abc4576053dbb5baabc5abbf33bd8b73d3c35ccd73bbef5f5bbc66023bd111ba2bc2e388abbbcb834bd8b055cbb359884bda51a5a3dd37a2bbd3639953ddaf5b03c44b4be3cf50923bd48edd6bca3b795bc2d23313b433f28bc9543c2bac526233c7ff2febd2647ce3caa086abd539baabdbc731f3dbc7278bb6e9b27bcaa24d0bc449efe3bff922e3cf94c863d9f8aa63b13a150bd047baebc49ecb8bd90b396bcb305b63c97eb563d653174bd5b9fb93d182e273c4071d23bb4478cbb8de4073d186840bd81bcf43c57cd3ebd37dec4bccead8b3b490517bc82b4c43a4cceabbcd222783ccfd4023d2d310fbd54144d3b29a1253dde0291bcc8752abcee01993c295f91bdf5988dbd37faae3b0c19bd3bf4001cbb2b87973d5abfa23d29fb89bde33517bb051c3b3d64e9bcba251cdcbd7b1afc3cb243793b4cdd413d91a185bc96d41c3c72fd3abdaab30d3d5ef2ed3cf8bbc23d2ae2d7bc47aeb3bc3ee32dbc9bb4d3bb4be69ebd8713da3ce6e8ad3c8085ecbccd4097bc9e9cd4bb9d3fc3bb8c718fbd08d9ebbc2120ab3ce4ed1dbd36c2a6bc14eaf1bc195091bd93dd40bc070b3fbd1c9932b9e0a73fbd862b80bc8face43d8951133dc61dfebc3c62e6bd8d93423da603993c03a8993b3ef3933dab4216bd0e34d93c5451f1bc8e9e8bbd1aa1c33ce49413bd7dfd12bb9d68203de1361fba0f94afbc92d3aa3d0af40dbefd4f703d0bc2383c3dc3af3c602e573df5ec363c96dc6a3ca0a8213debc84f3df905a1bcac94e53c7824313db56404bc6964903cace425bda4df143d77393ebd2b0e1bbd94bec23cd9fbf4bbe52cf1bc148b7dbd7a3ab23b58e25abcb42c443da51ba3bdbc736d3da80d2cbdcf57993cc9b2483dff91d1bc250b92bcab79a4bd4e164e3cc0ba93bc82fde63c2fc3bd3d9ebb7a3d232ad8bb69eaf9bc3b170cbde1dbb9bc8fd2aabd0c93d73c1a0a783b125ed83c255e113dc4c9c7bc17384bbb6fdbb33d572de1bcf352d3bcffc2a63dfa2c80bd103ec238805f89bdd58c3c3d5818cb39a0e9223c0a8293bca7dd65bd15f47d3d0181efbc79224d3a27e84abdd1bd74bd4fa41cbd0c9d743d461ad23c2e6d46bd081b2a3d2e7112bd5da57ebd51a4ce3ae7406ebc1a8d36bd6423533d2a1938bdbdd29ebb836132bcf29fc33c3006093d8f5f103b1761823d648d28bdc049f43d76f562bd0062613b0c94b3bd650facbc01b5da3c8e19a5bdf7ba77bc41fbc33ba882b63c1c6647bda049183d98ca1a3d015df7bc5c1846bc4eee7f3d6d0e16bdcdafdfbb51d11d3d592482bcd1475a3c5af12f3d36938e3df861a0bcc01032bde3e3d5bd769b1ebd90091d3d7be00d3d6cfb373d90168f3d5b7bc5bc9aff083d4a9651bd6ed3b83af7f70c3c05e34dbb60a152bdcfd3b1bd0df48ebc3516023da17b3e3dce025a3c8531503d995c08be5d6d87bc4c7615bd82e134bd54aa04bb05b872bca880063b69992a3d4af31ebd4ab28d3ce83c8f3d6813403df39301bd114258bcbfa447bd6b872e3dd48b583cb4d5293dff4282bdb1a412bcb0f9933d60356d3d4d3abcbddcfc55bdb3d168bcc25bfa3baa268fbcfbe0c33c680456bc17ef3a3d982a8b3c9ef3c4bcb2aaafba7d8907bd42d2003cfe0d593c606f143de7734e3d912c5abdb63e8bbd2e080e3ccc28303b150287bbfcbbacbd7c796abc58a016baa775fd3ccbc6bf3bd578b1bd229277bda1b6b9bc57542bbd9816a43a3a50143df29119bdd9e105bd6b74aebc50994bbcc623073d6f5b54bd7833fcbc5d311e3d49072fbc60d59d3b121d1fbd3d78d1bc2eb38ebd5d9252bdd9f3983d49e36cbdcdccb8bcc81e163e666c4ebd37b7f9bcd2bb3c3a8ba55d3c5edb0cba8926a2bc6d7443bbdb33bdbb3867a83b31b454bddced6f3cd96165bb3445a0bdc1ad903dfaab283c6be3da393e9d3fbd49bc563df33e0e3dd32185bd926ed53a0cc8d93b2f6c78bce826f7bacfb888bd3f0fe93ca997363ca7c049bccdb624bdfb7058bbd2b602bd6e01b33dbd6135bda64f32bdb366c1bcebee49bb83cab4bc792edb3c3342143d6ed38c3d9a3cf73c7dc0d83cf7cebf3dc7504f3df3c59fbd84be8dbd26008dbc3d6c29bd2ec2803cf54d823d1282a33c2dd20f3c8604a23ce207babcf13b143c2d1e04bd11575f3d20112e3c53a92cbb3197c8bc5768ee3cf18bdcbcaf87fa3c3cf2a5bd9dcdc7bb604730bd31e23fbd611cdf3a2115afba0ab301bda6b4f6ba1a1eeebc94d5ad3c510a543b9a3ce73b0b454b3c970c303d3d068ebc93a1c93c2c01aa3c875ca43d17732b3b2011063ded01d0bc22a0bebbdf7481bcc68e91bdceb5493c6ad24ebdd678833cec5e46bc857fe9bcf7f35c3c0c9c1c3dc5f711bd03e0ec3c2738823bb478abbd50a5093df9df71bdc72c933df48bdbbc920ff2ba9dd5943c11dd0abdd1e0c23d42640f3d92a05e3dffebe1bd78390bbd4750c1bcc3b54d3d6856c2bd98b680ba0fe6373d6470683dd59ddaba5d31b03d6b189b3ceb4e8c3dfeb2a9bc5016473cd47965bddcc5f7bc52e51c3dacb91f3cdb8ec3bd653b2a3d1437223c1d72a0bd84e0ffbcca8d1f3d	w600k_mbf	90.16	0.9395	2026-10-14 19:47:13.752275+05:30
3	1	\\x6fbebdbc6cb8883c870d2cbd8860733d6f5d9c3ca13d33bd22f887bd357bb2bd206759bd9a49b7bab39ee73cc052eebb0ea2653d11a0b8bbec536cbc184c9cbdd274b23c02d4113cc9cca53d60e1b4bb7ba8b8bcc47c0a3c3586edbcac85c63ce89742bcfdbf923ca816183d9cba953ce7d458baac2618bcc5cb83bdee943bbd99b790bd660b8cbd6209243dcf1c0cbda58cbb3cc360a8bd34134cbdc98cc13c076b743caeea13bd5b9e443cf11ca73cde328b3c356bfc3b6d5a3f3daf8645bda8811abdfc51503d94f6e23c299d8c3d0e16b73c6007aa3b942fd63c808f13bd3c681e3d4ea758bd8f00ce3c234f8ebc52164abd55f02abd0c4c9e3cd48805bd2df82d3d76cf31bd7fffbd3d839cb83d8bfccb3ce40b1e3d9d8095bd9f2fe8bc7ad2403de33b42bc0a2363bdd9e9cabc141bc5bc7f543d3da26226bda71ccdbd5394763cac9b81bb83f434bcd70a5d3981d2b4bc2a711c3c2c572ebc7cca4f3d1a9686bdc1859abdd55457bd4a6b3c3b2d18283df9e3ac3d189fa2bd87e0b93da1af05bddde1d93c519e87bbabf6483d8004a8bc4df0f63c927866bd44c60dbdc83c5d3c3e48853ccc25f2bc533217bc7d7d2f3c7e665fbd280e393df8f95c3bc7a0463c62801d3bd4e7a53b20c806bdec1d78bd2a05b13ba98d5f3c449f7fbd2d01463d0aeb09bcfbb82dbcd4fd72bc112a5ebdceb0b73d18ed4dbc8cf37dbdd6b6443d3b75493ce0e5273cda27bbbc6f7ba5bc89f10bbcd4a8893db395e33c7493893d3ec1c3bc94a132bcba043e3df9c8383c3fbda8bcdf7a0ebc6e7b19bdb5396dbcb96e9dbdb8ed4d3b8bb69a3abd1d27bde87c6bbdc99f3abd9a0a5f3cc15e88bb0d39d9bc57940e3d12dcd1bc024ba53c337d8cbc3d73e1bcc6f21f3c392d033d640e153dbe6746bd6acf423b3340793d03396bb8f9a626bd70a8823d5678c2bb5e5e49bcaf46fdbcd880dcbc7061d03d4fbb4fbd1224dfbcbbd4c83df98e6dbc986abebc3bff493d273d0fbef761ae3dec020dbc3613663d648b373d3e8ae1396daf213d7808e03c0e29503a9b57aa3ca3dc84bc4a624c3cdc77423b313a8f3df2908ebc54bc993c169292bce9657fbdf378913cd1a535bd04d6a5bd45af9ebd7cb87a3afbdd06bd92d21c3ddc6a853c2006dd3d09c8d5bb9600ad3d46168c3a94d9903c37cfc03c79cc7cbdf587273df9381dbdaa2c9fbcacc2bf3dbf66613dd0f7033cf7dadabafd05033d9e2434bd72168bbc5c417d3cefc3163cc51fba3d9562c3bc3965a8bd5d8a8abc57037c3d75131b3dbb7c2fbd7e421ebdcaedc03c5ea40d3d3b2d6abdbf6d163dda880fbdd8f0243d0ad3893ced85b6bd349abd3cea0502bccdcb5c3ddac5e3bb3a878fbd0e119bbdecdd0e3cd2108a3ce853013d3690813c5bf6313d2c8024bd4e65303dd5c95bbd65c455bc3b602b3d76d2a0bd2863953c709d0cbc72c22abc5df23dbc29ccd2bb8986713c1ae3a9bd8308ac3defeba9bcf9fb1e3d3e45a9bd891be13a87b42fbd59662fbd4adccb3c15b00b3dca0837bcb1e8efbc7f2cf13c4a98be3c2cd592bc88d085bcd737a83c4a0662bc4736a03caf8b3bbd144a12bd08fc303d5ea986bbf7a2503decdcdfbb9e81febb23328bbd37bf5bbd55b198bc8c7c7fba4eae3ebdc0b3f03bd1b247bd1857903d526197bdd607e0bc5b8197bd07125d3d1c1d95bdd8f7afbde8e9613c0f153c3bc922333c24142c3d29d1023dc993e6bc3e5eb9bd25f2a93b8168663cc6e658bd4a264c3d86a7313df32ab43c1eed01bcd1340abda8960a3d595b8b3db7354cbc6e8372bde78244bd0ac6c1ba20ff4f3d285e103cc436e73b441180bd1f43393d8403dc3caf1cccbd5479513d5e728a3a4eac893b41f8febc4209613cf90622bd169f6a3dff13a83d18d63abc2464a73d18a29cbd9d1462bdf96ead3cec59163ce7c474bb25b1cfbbc66914bc0b4d8c3bff8f4dbd58a90dbd67348dbd65b7ecbc9160f63b05ed32bc9ce3c93a5c9bc7bda8a31bbd913e35bb0ff9a5bd8abf793dce14af3b531549bc723988bc5b5004bd7f4b1b3db0e98dbdf7a96fbd8db8be3c7383083d92d4e93c41fc6b3d683d4abd2dcc2e3cd6fdd73cf7fc43bd81833e3d5f43dfbc92dfc43cca38cd3d60e83cbde7ad12bcb5f2be3da4ec94bcbf4b883d74e5343deee2c33c8cbdb0bc5999e73ba29bd6bb77596dbc7af94bbdba0c46bd41cafcbb16cd03bc631ffabcb808803b925bc63c970587bc5bd336bd1f9d08bba1ad013d8ea1aa3c89ef913b53480dbd289e843da156863c72217dbd800a28bdc521ca3c358c6f3be0d5ef3d5532e93cd52628bd38178fbc613518bcb9bc6abd1391413ce840ba3a169e293dec9de6bc945028bd8ca88f3dfe31ba3b1ece99bdb6c4eebcab6c2ebde5d09dbd742d3c3d467db53ce281103d113b003c600280bb72b7edbc339a963dd29f623c4e8ade3cef6133bd9f30893ad9fccfba22d08b3df5abb6bc11fe5bbb9e61b8bda2ec013cb80628bdea76643d36b882bb824f383cfc6f3f3da7e83fbd774a54bd8390353c14f33f3c288fc53d89b6343dc136883d0ead663bfef4ba3c6e7bb7bba63adcbb74f6563d49af053bf89265bd2783ab3a58abe23cb0b686bdb2705c3d491450bc09ca9b3ceeb83bbdb91791bcbf3ce1bca95a153dc1c6b83c6cc5b3bc2ca262bda0e294bc2dc3123d380bb2bd4ba1143d184d0d3d4deee9bc78e54abc2ce460bdc207443dd6c658bd5d498f3d089c76bd128e67bdf892fcbc45ef893dd8969abd001f753cc964893c12388d3d031e06bd80bd973da6e5c03b66c48b3dc6fd3d3da3dfccbce9b9333c70f9a0bd5772bdbb98adb9bcdb971fbd3d2df33c3a365f3d9a0131be9c1f093daf91473d	w600k_mbf	28.84	0.9805	2026-10-14 19:47:13.752275+05:30
4	1	\\x0e5c26bd1f4c83bd1c101e3bf9c9553d9c39a03c22d1f3bc3517573d0e339bbd1daa09bdb122d6bc37137dbd6a99853d9c97eebbb6c2023d4bdba13d58637fbbd896ed3d89427ebdbd66d73d2823933be16e7d3dc2707bbc097b9f3bf2fd713d686937bd8440ebbc634af23c436284bca79828bdf8845ebdadcc0bbdeee697bda083e93bdbd621bdec4eb53cab8760bdc94bdc3de8219cbde8d5513d7400163d603f7dbc32cb3abd2d8629bdafbfe93cd3c7613db8df0b3d9309d33a757fb93c7cb2ed3c5130783d47a00c3c090c8d3d9ed56ebd4e3129bd0871fabcee1628bcce1148bdf140a63dad2278bc68b645bb92d60f3a99e5453c1d74753df4c5b6bd564520bd45998bbdad6cd23dc827463d786222bd81a5d8bc2b2577bc25048c3d41743fbbf930fd3c4ea6163d4e64a1bcabc185bc031bdb3c3d772dbd0830c0bcb514a43c8f4cc0bcdf8b8c3c026956bdf1c969bb87c516bd2d54aa3ce80d4d3d70d0ebbcebdfbb3c6cc25ebd2f26233db86c853d1e64be3c5566bebc47fc4e3c63d916bc3012cb3ced0a633d21abccbcd7f07fbdd01e40bdbb6858bdaac7c5bd54fc4cbc3fced33c971b02bde75874bde14dd93ca41b433c40f0443cd0ec2e3c0003853d28d9e43bde579ebcb3ffe2bca9280d3d793ca3bdc54c4b3cf4d4103d125b013d958b73bcc4704a3dcce3bebc235b0dbdde99263d625c3f3deb0780bdf262883d41cf6cbc25f782bdc3eebbbc7ffc11bdf765f4bce9d0003df916de3cc2d3a63dd51cbfbce602233c244acdbcc0cfffbccfb9773c789c19bc878003bd3cce98bca32dde3c5e75e8bb37f2b7bcb83a7bbc94f781bdc712213cd908743de3847d3bed00a2bb71097bbda9a138bd76385cbdf85a5fbd2d6dbabc4284033d089d0a3de6bdf33b4e0526bd6ddb67bd6c94013c8e572abb4a800cbdcee8253d4376eabbf7096d3ce8be2bbd7cd20d3cbc3c0f3d999bebbbdec450bc7865033d02fff63b6df70dbdb062013c4c15cfbdb805843cabd1423cd678b5bc1e71633cd0fa66bc3c755a3ce78ecabbf5d02ebdba779d3cde378fbcba252a3dcb884bbd48a3693dbf47c7bd44a293bde9fde53b7b6ae1bc367b11bd5bcebd3cd95338bd0575a1bc47da09bd88078e3d8fbd62bdd7d0853cf973743d79c29bbb9b1ab43d039901bdabe4ea3cdb96993ca9b12cbd388d8d3dd73388bd133d83bc3bd5ed3c9fe78b3be9c4d8bcfe0651bdc54dc33c9e1aaebca76a71bdffe285bc8841dcbc35ae763d8cef323ce013a6bbbd63a53c6767e23ca2f663bd7a6db1bc698bdc3cfb3a43bb44df7f3c4fb693bdd0345b3c97fe70bc0902093d3203d3bc04dab8bdf5c0143d9a16683d812bb8bc90ffdf3c22da46bde57410bda367023ee88867bc829decbca2c4383cf7172fbb2f5e9ebd055f81bde204253c132e923cccf6813dde09d6bdf0ec123d0029813c7bab8bbc48d4e93cfd6a23bc33cb633de15c4cbd3fc3893d48eabcbcec6e21bbb80e23bd8405833d99a551bca3c94bbd9d8ac0bd5258913b6829a73a54e04fbc7257a13d156a45bdbb01c13b1b437ebcd4b4213d00112d3bd04b213d2b60f83cd126923c80e524bcc5eb143d95c6c23d913e963cc20c44bb9fd69fbd68c89cbce1fc243d9513133ca99309bdd06902bd2654d63be9f71c3d28d28cbc0251f83bbc15aa3d32db423cdfd76fbd6e1eeebc10c9f5bd340232bc4642dd3c1df09b3c503d84bdac0db5bdd9816ebcd8d206bd393500bdbf3a963cf066c6bc7d54483d9ead8c3d9964b0bdb911623c578620bbe0378b3dd940b9bd413f813c76549d3b968bb13d9a0f39bc5cc0133c27cf23bc6024333d6662893d8e5e3fbda1b01abda6a38a3c5ee0003c05a2813c0f260cbc870651bb0a4f30bd4128c23c1b90c53cdee073bbafb3943dad8ac0bc325aa43ce566853d6f20773c8dd5053d5b1646bd45cbf2bc1a4fbabcaa2cad3dcc8e393a329525bdbd89bebddf39483dce8deebc3f83063de35a64bd0ae987bdc86e163cd11d7dbd90ecd43c956d32bd3e138dbdd471d1bcdcb23ebde6b6dc3c1caee73ccc5cb1bd6aa9b4bcc0f6e43c3c5b9e3b437c6a3d3bc61fbd42570fbdd0d8abbc0912cdbd0425a63d666e063de0492b3c941ce43d41de853c064436bde333a03dc89e893cf16b3a3d0b0eafbb45b39a3b1edc12bdb18bba3cbdb73e3ccecea23c3b72c6bb7dbdd7bbb4a5383db4d4c43c25e4063d41d6d1bc84d21d3dc4d3d33cbfe222bdd61b13bc692123bdb4dd813ccef2933c7fe19ebd7820ef3b74b4303cf7042e3b0271003d8189263d5674453d5f1c4f3d560c98bc3a9996bb659aa4bc83a3afbd29f7d73cbb2c90bd8113e23d315bb63c8b47583c306e3e3ceac8ac3d5c21393d59a30c3d2f700abd54020d3b11caa7bb9371de3b7a46083df77523bc5f8a943c7d5c623cc817f5bc41a7f6bcb261a43cda5a603d8a7269bba081563daf7cefbc1f0a9f3de36c17bc893ba33b92cf0dbe79879ebcedd1183de1cc09bc0314d1bc86ae37bd068ccebc0b4181bc2ad317bec939a23cd1af503d814f713dd570993da316213d215415bd385e4a3d92dc563dd7784ebd178e13bd9d34773d7e61bbbc89020dbded58523b9e1e60bdce1ef2bbc2d8123ddd08f33bccacc73df5ab9dbcce923fbdf70d2d3da2c2893c3b09d4ba6d2d6e3c4609f03cac1fc2bba11482bd90bc58bc4943f7ba51a677bd7817403cb059173cb8bb863d0c11a5bbcf790c3dd0568dbd30d7d33b76f093bbf7cc0b3dad2fd6bc7c754abcbb814f3cf4a016bad467d63c09416dbdfe14953c7fe993bd3111f63ab1478a3ba9e255bd5ab69ebd4b8f37bc768b60bb89ba96bdbb9033bc2e803fbcf86ec5bd33c46abdcb7c7abb	w600k_mbf	147.5	0.9998	2026-10-14 19:47:13.752275+05:30
5	1	\\x7d274f3b853086bddff4033d3ad0d53d3d4aa1bcd4ef6d3bed9adbbc5e3bd1bd09270dbd779ad53c08fbb83cd4fdf7ba03a93cbc972cfabc706f8dbbfe5024bd722e943dcc754cbd96ac4b3d14a6093c85ee983df36e07bc27d5f23c7237c53cff823fbde4ad8abbc11e793dcd072f3c6a580abd8da4b4bbfde703bd415aedbce8e84fbd2ad369bc083e9e3d6b3b81bc58e59e3d8663a9bd800c953dafc2fc3c30f50b3d31fc48bd8824bd3ce926dd3a04faf23c7b1c153d91c4213dbd2a16bbd531bb3c758f673dcbac173dd5425aba482d003c95b7e7bb8f5589bdd1487ebc0cb0553cc85e54bc6a3422bd36b1d53c6fd8c1bc93c7633cccc8e63b12cd61bd4b323bbd25578fbd4e444b3ddd90de3ce9b951bd51eef33cf9b978bd25c43f3c0a062b3d538c1e3b15de4cbb34153fbc89781cbd815ebc39fbfdb3bdef54a93c9294593c787e26bc2c4ccfbcfa3612bcd8ce24bd3174dbbc4bb2b83cbf16213d0e9ed9bd991156bd5e6e03beb25da03dc2f6873c0377ecbb16c4033c3c87a63dd1ef003c8563813d740dc6bbe01a733b784ea0bcc190a23c6aa2843cc3b7a8bd91f44c3d07f83dbdd7ed54bc9e914dbc18d750bdc9778f3cc886573c5758133c09d2263c8a0c24bddaa682bdf601063b19089b3c8a2478bd630e563d64d477bd69aa06bc5a3d483de1e9c13d4c5e0ebdd44f64bdc92ed93dffccb93dfd0bc9bdbcaf403dcfdfe1bc629a873c1ec088bc2d508d3c863234bc4b5ed8bc5fadb83daa1d9a3d9e71c03bc0c58f3d4ca2ae3c8d1757bde91bacbb2316f93c196606bc6ddcc3bc97da1ebd4860283cfb2380bd5e7462bd46c44bbde772b2bcba3ab63c8d59f2bab9e1803bc3754cbdc06ce4bba8dda4ba05b5f6bcc16a23bd875851bd1470443db086c53d45aca4bd49a30abde469d43c9e53193cf245063d8608f8bb95d882bd29cc3a3d5a75253d7b5219bcbbaf403ddee5c1bc262e9ebd0a1c3dbdc7c084bd0e05a3bc7d12043d4dff8abd7249603cbdd898bc41205f3cdd38803d7306b83dd632cfbb318cf23b628d843d2f96223ddddc3c3dcf64bb3adf2398bc5bf32f3da0783bbdff06433d4d83843ccda2913bff7b91bcf14db83b24f110bd2173233aa7f3cbbc9d19f0bbacc069bcf66ea8bc7bfbd53c837050bdaf41db3bfde4803c7f2b933ce76cb53c82b1a4bc82a4423dec2864bd79476f3b1050f73d58d0663d671408bd5d1acebdc8177a3bc6330fbdb39cc7bcf00f82bcf4b391bb6974173d76ca7b3db028cdbb6bef583bbbb4b03b6d09d73bc85462bcfd89153d4af9a3bcc824643bcbb930bd7ff288bb4e1f7c3c0cd0c0bc8e02883c4dfdc2bdbf8399bc450f023c09649b3b874085bd735a85bd215552bdd366c93d985498bcbd46b83c337b4dbc42cc523c96bc77bb2081503c9eaabdbc22a5a43cdb37533db16e0abdcd6a8b3c84a689bdbc8192bc614d86bb7130533c31d59e3c8adbbbbd595df73d680c87bda26c263d5dd5abbd7aff1cbdf66ed3bb2b2bebbdbda7703cc176583c630ef53b3f4882bd23c7553dad05eb3c3d43153db595a3bdad19113cc47c1f3d9d5b0d3dc90c043cbda2fdbbce43cd3bc502063d8bfea83c90caa13c24c1a4bb8d36d1bd459d2fbd432fb2bc1d2617bd6aeb143d3900603d0a169cbd25df473c86e1aabd7ab015bdd8c547bc24e0b4bc257894bdcfa9aebd3a69debc2ad35a3c262e753de7076b3d9a4e333cd970ecbd4276afbbf91600bddbc485bca4d7c5bcaf6d353d4eac043c0288213c8ad193bd5aa0a3baa3159a3d4a6e363dc0d592bd588e093bec834abcf767193df807e83c562909bd25751fbc06b433bd6cd3263df3f7a23d35a4d7bd4b363bbd0c11113cb495b3bc850a0b3d500a903c42b4e63c72daee3cb0d0453cea9d85bc608b69bb528ca1bc1539413d595d0f3ca4e284bcea8e2c3dff5118bc103d33bcb648b83b4c51813c3bdb37bd75a27fbd0cfe39bc09035a3bf71076bdb81fcfbc1758a5bd369579bd15014f3c9726e9bc8b53a4bb6077ca3ce0c00cbd5dabedbcaf0c023d4129743d127cd73c61a396bc7b7cd1bc63294a3a2d5a1bbd671f143d3fcc42bd171c52bb3f11a23c1642c3bd937ff03c1326213bb4d4df3ce4def23dabe0afbc566f84bc49c1113dd4c685bc3594b1bcd942233b6e3b84bbd0dc1fbd8738213d3a067fbd4de0efbbfbe69e3d060a693cac12e3bca6acb83b949beb3c272019bdd44f883d0a2d843ce4fdf6bc5cf8cd3c17d3193d6385b4bd1b13c2bc9437edbcde0ce93c8935873b325387bc8994803a80dd9bbc7bc7e7bb251aba3c03fd03bdfe9a593cd849883ae70151bc9b86643c2e21a33cdca3163d70a48f3d5832613df043983c0f13803d9d10913c5ed0d3bc09c3aabd83e581bc83050d3c99228ebbe5ae5a3db63e153ddc55253d3d69613cba250c3cad2cbe3c9a8ed43b2c3c9c3c11dba7bd5bc9f53ce70150bd5c8d923c30780cbd7cd9673d297699bde99474bc5e6c2dbda0f319bc4a4bf43cc15148bd517dbd3c66a9983ce6240bbd3dcf623dbbe7533dc22c033c78f798ba340d473df21831bc7bf8ac3c1088123be4fc263d0291e1baa8ee9d3bf070b0bd0688b9bceea6cb3b34d9c4bc8d2b89bc56b20bbd3e59cf3cbbc3a83a1e6bbd3bd166bf3c48850c3db8658cbdeb45d3bc4497163c1fe64cbdabd58a3d9cd6a2bd486e1c3d067c24bcbf7fff3cbc177a3a6563f7bcd4ee993ddc1a12bd3491803dcdcdc8bd8485f5bd7e588d3c51236e3d2dba2bbcbd11ffbc78b73d3d6aafb73dcf6881bd9bd15a3d5e94393dbb7c553d2e9bb4bc6f8c163dae5575bd601f97bc75ddd23dc98ba6bc528fd7bd61b66d3d5f9ecd3cf4f8fabde5798fbcc98200b9	w600k_mbf	15.14	0.9685	2026-10-14 19:47:13.752275+05:30
6	1	\\xfb8cb0bcb3e05cbd6638023d47e53d3dc84a5d3c3aa3c2bcaea0c6bc9aead3bd39775dbcab9b97bc7dcb923c20aa9a3d59d049bdddd4903c73d3bf3b28e2dfbd716eaf3d0df98abc00eded3c4fdd1f3bc14e7c3d4bc34dbd5d8a5cbcd401733df008f8bc4cd1bdbcb50dd43cd14b89bcdfd2353d23fa24bd35ed86bd361d07bd720f85bdb411d13b263ffe3cdaa169bc252aef3dbf4fe2bd29b6813df36a4d3d9f8704bb9391bdbd386b09bde058e33c8f30543d652321bc46ff663c3627073d7a68013ed836843d87e4503df6e6403d9fc5913c2477d5bc8af5fb3a4a6fbb3c75532fbde6b8c3bbdd89cabdb761573b7995c6bc3e784f3dad29803b8f9dd2bccc78413cb03567bdedb4353dd12c0f3c4b195bbd2996223c91de44bdb595bf3ca073953cc418603c9493bebb20e3b0bcbddea7bcc03ef23c088d98bd1de438bc0e8a6a3c243ad43c9b6602bcc21e8fbd291949bdc4acb6bce8b42b3da8a7523c1b01f7bdbf5886bc7eefecbdca1fc33cff7ca0ba75cb003d747213bdcf67be3db93b2ebbe81a2cbc7d6010bb8768c83d704952bcde4829bcf3a8d5bcc20556bd1bcd063d387dcdbcf97035bd8b21ecbc334cffbc2634373d1342bc3c7bb43abcdf88403dcec986bd13d1d63ce5c8f23c7b488a3d7d93b0bbf94f133dd40d863d4471253d08fcefbb2f8cc23d52c10bbdc89907bd347b283d99eba53d731459bd8cf8c83ddc392fbd1dd7d1bc47b167bd6de4213d518e3bbc2b0e2fbb783f863d6a95a33d68224ebdaf27cc3c2aa41ebc20988dbb5924eebc17673d3d4b05b6bcb93fcebc3d4132bd2d03afbca8bec8bc6a3d62bdb13a6cbcfdcc42bd0b4e113bb1424bbddda26fbce66d4ebd90b441bc2b8926bc66c338bcc334f7bc6b1368bcd530e83c92ee793d676d90bd40d9f9bc4f0667bbf0d707bccf3e5c3d2b47793d6cb114bdbd9c4abb5de133bdc5629d3c2af78b3d0ebc6fbd57d683bd8c88a4bbb15be1bab0599c3b23b1c13bbdee173bbd04cbbb671ccf3c00a3143c3f7e563d7a514e3b094d3fbded0dcabcd28e173dac8e7c3d0f40adbcf9518f3d7270c8bce33c5f3d668b9bbdbd385abdd1debabcc0efdebc9017ab3c14e7033d3c7280bd10c59ebcf858acbc91cd963de6b589bc9088a13c4babd5ba2da043bc58ebb23c87cb7f3c0b1ecd3ca90a57bb3a5973bdaa3db83d9134f0bde332873c6dd35b3d297f593d644dfdbc79b349bd120b033ab5478d3c9360413c9bfe83bc8db0d3bba8dd733df8be143c8c7163bbf5ca173dcb72053d3403833cc4033dbdd0d478bcb45db8bc2165a83c9757bd3b4eb3813d8c9db03dd9de46bc39cee23b358d9abd446dc6bceff3dc3c33329cbca219463c9963d8bccef336bc1bdfa53d6d49cebc434bb23c7433b13cda74083c307a6fbd7eace2bc6ea01e3c00c994bcd96b84bbfca495bbf1b37f3df8cdebbb034b17bdda5fe13cff7304bdb3b04a3d878883bc0910a93dd1dc09bcd996b73dcd810fbd0431993d5c8828bd0d9689bd3a8b44bdc0ed383df93f973c9e52a2bd193d8b3d4746b13cc6de313d6e2e99bcbfda713dabb31e3db607823da61aa13cf4d0f03c8a027dbcaa566d3dc1bf963d6830803b63288fbd7d1bc5bba26925bdc862593dffe5c73cf748b53cd424113dc9ae8dbd4a03c63d96a009bd7ccf36bd208f503cf10345bd1a866cbd534a6dbd76ca9dbd5da1a3bc3fbe923c729aff3cd3d2073c6c20a0bdb9c13ebcd74126bdc12d53bd08cc963d7b375abc0edcb2bc29913a3c567319bde3bf55ba5a3e473cb2740c3c0fe9f6bde4763d3c6ca59f3d1330823bc61ba63b7df354bccea5883cf21336bd83f1c63da727113d407373bdd975babb5e08943cd38e203c0eb388bd267e55bc51487abcbea03fbd4275b4bc5f57ae3c924f2e3ca66e83bcea0e24bc0db5643db2b2b4bc0256de3c98f0223ccebf10bd3ff8763c0b20d93cf73557bdaea89bbd4e778bbdfc3e45bdcd122ebd040d8a3dd46ea2bd1b8097bcbac0233d2ae435bd1212303d2a64cc3cf77f6bbd6a52263de97535bd52460abd5bfc383d049b43bd5a6692bdf227d73c5b7ccbbb5fcaa03ca70c19bd5d32b5bc05ccafbc231b90bd83151b3d8d821d3d08cd64bc255df93d46fbc9bca253da3a1fdf8e3c07699ebce01ca43d7298ecbc8ca9213c391d75bd05078bbcf4b392bbbbfa783cda6f383da635613c19dabbb92b1933bce7ce11bcbdd3613a7df19b3df7c95b3d05e9b7bb2490f9bbf71305bdba6b63bd3d4cd7bc2724863ceb7433bd280bed3b76db6a3c98f0a13b2edca73c3ffeb0bca58d8a3d168e0dbd1db931bb5a004b3d7b3652bd5efa483dce76f6b975df923bc0ded5bc39c102bcf046943c48cd273d83fdf5bc05abc8bb171598bd03cffc3c03f1b2bcbbb7023c7d95b43c82a8643d4a4c903d6af9d3bc8ba88e3c4c97bb3c8965033d533c4c3dca66823c7df4323d7d173dbdb3e3de3c64038bbdd76973bd756db5bd7df31ebd8cc26c3c502b6abc4f8b2b3d6cddc6bc3960debc01228e3cb0e3c8bd9110aa3dc116543d68d1ab3cd7641f3df8da053dbc4861bb14ee843d7ba7783cde49c1bc879d0c3d4dd24d3c13eb83bc9f37c63c43fbc13cbd3dfabc58bea2bcee7dc7bb8e7acf3d980e6d3dd17d4e3c28c2b93cecc4153c0c0d82bd208bf63c9b17bb3ba15d8cbb91af023d658ed7bca8d69d3d950c623ba058aa3c7acb923caad82d3a688dcb3ce3887cbc2ed59e3d46c512bd82637fbdc3bd843c392b7e3ddc3c03bd4b6c573dcbeef83c22e64d3df84431bb1db6043d93c2de3c62fc463c66d79ebc1dffaa3dff9996bd5bea82bcfce72d3d2e46233cfe4dd7bd1b698a3c0d4ef2bc65f101bee90152bd07f64a3b	w600k_mbf	20.61	0.9879	2026-10-14 19:47:13.752275+05:30
7	1	\\x9a16cb3ba7a6b6bd71ddad3c069f043e687532bc24c0b63925a765bc2d3bc4bd3af89dbb1823f23cb1736a3df5cc8c3d55bce83cfd00acbc3c13b2bbe060a5bdcd15c03de250fabcc643393dd8203c3d1021a83d0f9c05bd0404ccb934be983d55a994bd64a6af3c117d863d476067bb8f5da0ba59aba6bc777de0bc2af62fbd050d1fbd4d2a99bc7aaaaf3d961e5bbc9258ce3d5b5c6ebd94e28c3d502a09bc8dfa1f3cd248a0bdab0394bc70f9013c00cf5dbbd95e25bd1211d83c4841aabc0366403d21f31c3dfbe67e3c2f1818bd6b7fc6bc071c0b3c78dba9bceb46a33b562ebdbc2ca7213d53761f3b75dc603ddbbea0bd773d013be2d3fb3c810187bd8cbe7ebd13cad7bd95401e3da88f0d3c23292ebdef72833cb5b0b7bda5cc10bce70c6e3de0f7213c30968c3cf5dc05bce67c12bd24ad9abd356658bd3c3645bdde0f2ebdcb1a2fbc61f30ebcaf08013cd471813c4c9e56bd16de343c5aedaebc189fa7bdfd271ebd107637be8c9aab3c651b533dc81e7bbc1b170cbd57bb953cc9451cbc25bf2a3ce9c9ce3c982b483de20cfdbc5b28923df46e103cb06148bdc978f63cddfe7ebc261747bd108de139317c90bcc0ba843c17aad43ce7bc35bd2902ce3c2b39233decbcbc3c0d7c313c1cea2c3c68fca03be8f8cf3c4cea143d1d24603a95bfad3c21aab13d4925c5bcd0f25cbcbac4923de800a63dc05e9dbd721c6d3dd25134bc200b04bdbf562b3c2e8c433df42f0cbd60d793bb4d01e13d1bb9a33df6311c3ccc04073cc3520dbd9005e6bc45a5503d190a123d92bfc33b839e3d3b537917bdfd7d353db254a7bdffcd5cbdab1ca4bd2510c6bc0b44bb3c5d77f13c40ce62bc5affc6bc250c62bc3dd5dfbcd14e7ebdcc693dbc3ebd78bd47b9883c96564a3dbe7168bd8a8387bcaef949bd1a4eaa3c90dd173c5bc0ef3c0a4d91bd370e1c3c7cbf483d658d0d3d8a28263d9feed7bc719b0bbd12c909bc84318c3c4517a4bdf3fdcd3bdeda29bd17c3303d373574bbb11989bb1355303dc708c73d16b247bd3a18833c72905b3b053d8c37a8472abcd5734ebc18dd7dbcd9623c3da10c64bcb56799bcd77fccbc49f32e3c55cab7bd3795e03c691a22bdcf5c86ba07090dbd7cae143c369698bc013ac73c277a2dbca5861bbdc5b6913d032753bcc705ea3c00e8153bf0895bbd9233843d3b6403bd29cd113cb76f2a3d15e5763dfb7540bd0792a3bd60e716bc49ed82bd9e66143b04d4423d44ac6f3d45291c3d698a8c3d8e3f21bd5e60babcc631f1bae779e4bb57dc48bdb8316e3dcc3e3a3c1c2682bda99280bc5d5efeba2986ee3ccea0e13cd5a95f3c9ffc84bdf740e1bbf5383cbdf653c1bbf7a301bd15ed02bdfb0ba1bb7dc41d3d75b740bd70c031bd7cb5a13b2ba8fb3b740d43bd0d9a69bdd9fbc3bcfd579c3c600a2c3d9a5085bb19951bbc65a47abcd00356bc385a183dcb00383d20af233c13c364bc5fc3003e43629bbc1df0ff3cf0e698bdf78caf3cb933503bbce983bd3f84d13bda4233bc52ef113d7adc9abda7ff213df2acca3ce19e383d921e1fbd61fff83c2a31303db2631e3dbd95dd3ce5cee33ce17f853c03caa53dfab25e3c70930bbd7461513c379db3bd45dc8bbde567313d89cccdbcbacca13bb67e5d3db98e85bd85a8663d968734bd2aacd63b9da9313ca52e42bd6275b2bc1b4621bd4bf975bd4bf3453d06fab23dd3ba6b3d927880bc49c224bea4cd543cea22e83cc16284bcab7425bdbc31e6bb956e5cbdba6c22bc2c98f6bccdf8cb3cd422bd3ced2486bc6780e0bcdc2506bcfb3f933cb318703d486380bdc496063c646a63bd5f7b07bd68ae943db7af903d7f38dcbd036523bb8aee853c034b2ebd98d9a5bcc1caa83c02793c3c715a503c64ef42bc42d30bbc6db09ebc44394ebb4d4823bd3452353d5868a4bc868bc83dbfbf133d9a7dea3b1ce4c03cec4f0b3d476c58bdb19895bd8d65083deea296bc998f19bd7dbcd03c197fcbbc4da985bd99031ebc0fe6ecbcf257b73d10e8883c909005bdf05e253dc0c383bb8ec7203d82ea973cbccd993b7d4f92bc9d127a3b1a2796bd263c193cdab31cbdafb0a9bc96fdc7bbfdf991bd732a633d846cd63c623a1eba784abe3d053b39bda401e7bc90f426bc7502a23c3368293b45a0a53c5f1eaabbe47370bc394fc63c4eda81bdac117cbc5433a03dc414103dfd8d42bde31fec3c037cc03cd71285bd4dc3353dafe0bfbb1ea34dbd1d44a33c787cb0bb20eddfbc21cc2abd120b0bbd04042c3d82598e3b22e960bd3bd7063d3fe3473ce83f7dbc5d46043bd8736dbdd61cb7bc2a47753d17c766bd86630b3c02ed47bd1f19213d3896613d12e0013d2fa0323d2e55933d2c14593d087888bc1bd15dbd889572bc580372bc3b4a083d347aee3ce76e793da390db3cab580fbdd75f98bc47b2083d8624efba408806bc13441fbd8c69e73c2e4d02bd0f2c92b9675f37bd132d7f3da0ed13bd32c9e8bc41351d3b485d813da54da73c1ca671bd49d47a3d26fd9e3cb4ce8abdca14303de758e03c386ee03b6c50e53b48347b3de59b7fbded9c193d416b113c8794623d163ad63ca34a14bd253947bd7a0c9f3bbead01bdbaa8aebb99fae23c13446a3cc9f35a3dfbf5d53c522d5f3d8b701d3dadcb02bd07694dbd87bf83bc0c871b3de6dda1bd833e353d9df3a4bcfd659b3ca1d03cbbf181153b2b20fb3c6ec2bebcf633523d345f1fbd31529b3d6c0deebd3abb15bd4e0a51bbca35933d9c9ec23c7ba9d43bd43df53c93da353dca3c2dbd8b8d6e3d8103d23c64395e3d03f0a33b968b6d3d25f6a1bd047737bd06332c3db6c40a3db4f7f5bda9155d3dd5a9423cc74004beeba29bbcff4ef8bb	w600k_mbf	38.88	0.9643	2026-10-14 19:47:13.752275+05:30
8	1	\\xda519e3ccebc63bde9253c3b67a2633d9cf580bc300fabbbf20e5a3c2940edbdc135b73ce35a14bd102f4d3db9f4513beab5143ce094233b6461cc3b249f8fbd4def163d117301bdd2508e3c10e3983ca066e13d6ecb923cc4db18bd36c8973c703121bdbe005f3de75d91bcfeaa143d53d4a4bdbc3cf9bb81530b3d90f6a7bc4a2fa7bcb0fdfabcedf28f3cf07e523daacf033e2b5703bd3c5d813d9849ce3c50b6053dc5b55bbdc98b93bbe7c0473d8020753d1bd3c2bce4c4913c664976bd1c8cff3cede8863d8f1394bb03da6d3aa5eabf3c2f8c6d3c80d113bd1b0589bcff20da3c11bb4d3da28f15bc1951713da07a9fbdbeaf013d3eaf8b3b18ed5dbd4397e0bcbfceedbdd333423cb34059bcc24e07bd680353bb169f77bd0200363dbc87d53cf297773c001c9e3c59fb6b3c8543ad3c5918123b0f1cb8bdae7f59bc8a3d55bc2d50a33c895a623d47c55ebd4dd308bd65b890bcd9dd823a4efdda3cf6b6b0bd2b68a9ba8a40d0bd0a5b313dc9d9323d118dd23a8c640fbd8475ef3d716d9ebdb8231e3de7f46f3cfe22d03dfcd027bdaea509bd78d411bc873ba3bd1bc1abbccdf343bd425c7cbcd8c64abd9f190a3ca673ce3baa8dd5bb42e199bd5486983d1807e23c372a603c5c868c3da2a0a8bbb1635abdbbcfbf3cc33c513c52ba253cdd0873bc50aca03dc46d08bc0f64f83ad0d92dbbcce72a3d4968bebd7e0f833ddbeea9bc020792bbeba157bc8e1b1b3dd6010fbd2b89323c7c45af3cb56a8c3d5fc1a6bcf3be073d158de83b5b492e3d33d51e3df13312bd8f2b433d433a36bdf5e4d1bc6bbd95bb01da9dbcd89e99bd21d4443c4d04823ccda4ab3c5ee488bbf88e96bc9982ebbc882cf83cf0eda1bce1b80dbd61485fbde6f68cbd4bdc1ebb447da83c545832bd5541d2bde4bed83c6e8d8abd13feb73b4649123cd6a017bdb73cf33c7061103d3f14323dee30753d028491bbbce378bc37fdf7bb6342e9bc9e5df6bd9322a63b0d8499bdbf923d3c8f884fbc72ff3e3d7366803d907d403d143a0dbc7a63363ba80a8cbc84d355bcd6bfbcbc2718143d809853bd42065f3dc90a9fbdd96320bd63a72ebb58478ebbf3f0eebb7b3e0b3d0f2066bd7915203cab6982bca7df543d282f67bdf25d1a3de66898bcdcc7cdbc997e123d5459793baac4423cb3dc883cb340aabdf124453d8d3a8dbd8eff553bb839c63c48bcea3cd59003bdeec5d1bddeffb63c75ddfcbce468c7bcc081563da9fd4abb49354f3c1bd9b73cb80a88bd4c6fb13c13a4a7bcd85a953cb400dc3cc801003c968b84bcf3b316bd9c19bfbc0438e53c5ea2983d9900b5bb2603583d0ddb13bddc940cbd3b5e53bc859a06bdebda74bddb0015bd9add11bc6f483d3dd0b3edbc966788bd3f27cf3cfae582bc769c8cbd916133bd3d4f433ca94153bcf7da8b3c351fcabc153e5a3d9ce17dbcea4cb2bcd28418bdd487563cdcb0ae3c7729bfbb754abf3d11ceaabd49e7473dbc27dbbdda9f0a3c2e2553bd4fab94bc62043f3cc95f313d7415fd3cc980b5bdd93bf43b6df214bdaf5894bbe81d1abde2e3103d2d66bf3c4dda3c3d97e6653b06db5b3c6fcde4bc56287c3c745da33db65b34bdf4169fbcb2e120bd1b5961bdadcfc2bad98bf2bbf2a4863cb589a73cae62d4bb74379c3de6e20ebd0d28b93cd07cbebc10f403bd760c3cbd06aa26bc9aa4d1bd680a603dd6903d3d3ab3493d53bd0ebde72a19beb506dabc815e223c831440ba404d683cf8d398ba66b21cbd9fd9273d8ba5e53bbc6dbd3c2ce8ecbb4442d2bc01059bbd22d1a0bdbcf80abd9170663c6c10323d269dc53c64d69fbc3cd2ffbc69ab9c3d0b27f0bc79c9abbd8e86043c78d3793d6851d73c91a060bd8f6f843d420633bd384f70bcd61350bd6005fc3c8eece93ce3ad82bc001da6bd65c3363ca5d5d3bcd262db3c779c00bd984a0d3d07cd96bcfe7a853d5c92643ad93c78bdbbbe853df3ad88bdd08a50bda35f193d8b9f26bde710873a25b3033d01fbefbdd32c883dc9e9c9bc4cd1bcbd926d1e3d05e32cbdf26361bc450fa7bc8a3178bd69624a3c0143873da6cd72bc1d18af3a7ac384bceaf661bce61b43bc0a7a4c3af8f2623d740a613d8dab83bd2f98783dcdf99a3b5af851bd2e72a63be64cc838c9c40f3dee33213b653e303dcd04aebd464f423d9248d63c45acfa3cdfec7b3d21144e3b564934bdc3f7ec3b9bd704bb29ebb9bbd103863d5adcd03c7c8a8abb47f78cbb87c020bd1d7a5bbcd47982bdbb99ac3a05761abc7fe1d3bc3b9780bd69629fbcc12012bcb89d5abceb19f23c7ce92abd72d346bd1688853d6bf876bdf4957c3c61a97dbc2a4a0e3daa157bbca02fd33cf2813d3ca449333d85ab523df490083d2f23b8bcdcf4bc3b79cfb7bc45b18f3d6704c8bc5950663d76e58d3dfd145fbcf06d56bbab9cf53c35de50bcfaa6a23b53e9d1bcf7a462baddcb2dbde2038b3da232c83b4f63a83b92b316bd3b8ebc3ce961c1bc6f7171bcb525bd3caa327bbd0889a23d95e717bc289e80bd3d65c33d1582693d96c0f53cd016933a1ffc1a3df6013dbcc1affd3d4b1c213c08005f3c936e1ebd8494ee3c3fe523bd30e225bd237311bdc8bd0abd5d07943c7f624a3ddc2ea93daf47203d1d47d7bbc435ec3bce4bb9bc621133bde68b953b7477f23a57ad9dbce5feb33dfcb027bda562a1bcdc185bbc8445033ddfbf8c3c7be43ebd941542bc923b203c753d8c3dbc24dfbdcbdda4bd66c590bc972ed23df7199a3c7f8140bdfd73c6bb2eb4263c631e63bd756b2f3dd817963cc923593d9018a43b7a3d613db78ae1bdfbf2c1bd03f1a83ce7f97e3ce107ccbd46f30e3dcac6e8bb231c83bd538b88bdeb7d063b	w600k_mbf	67.82	0.9942	2026-10-14 19:47:13.752275+05:30
9	1	\\x592fedbc404a4ebda900063dffc8833d5cdc2dbd735ca23c567288bc9f821bbe119c8abce3b1f73b9eb32a3d8c23b6bb4318773cd935523d7c2f793c27717dbd00a4b13d5bbc8abdc07f693d488fa03bc1a8cd3dce9c86bd9cc4023d27eb913dfe1e77bb89d2913c5738373ddc60e83cdfb7f3bc166303bdc206063dbb2770bd023c9abb57b238bc40f7863d6e5db03cddbda73d312a99bd9b8aea3db0328a3d4c24ac3ba54221bc8330c9bb51cda83c2de4583d1658113c1b3af83c2d2442bd7dbd953cbc6cf63d5f3d24bdff039b3d68258abc8f4a64bcaf808abdbaeabbbcfd31133d26b19bbcab7c3dbdbe9d083ca6ebd03cbd2646bc5e114a3d7da7c9bd1895c0bcc3637cbdda9a4f3cfc3577bb7b5f553a654ad63c5389c1bdb3b30a3d9580d23ce985633de87d473cbde9893bd55502bd247b3b3c172324bdd351aebd783b713c10ed47bb2062a43c56682d3d851acbbc75c7c9bbbd66b6ba79ad93bb0d0d11bdce8119b9e73b4abe240414bc742a473dceb1e8bc8c1ef9bc28f48f3d0e5f84bcd037fb3c4881f9baebfc9c3d2db2f7bcb6d29cba2f622a3c50916bbdf72016ba617d83bd012e95bb26bace3cdf521a3d824d1d3b1eb402bdbb0bcfbd999f1a3c6f550f3dc761693c04971f3da747883c58057abcfde4e33bf690c93c5c673b3bb952723d71603f3ce56f86bc57b139bccca2a83ce15b9a3c9a5525bdfafbefbba62d81bc7e1ccb3c1af7093c80abd23c473726bcfd9422bcd6425d3d3e43b83db5233bbd4a4f0ebc4e41763d914307bd414dc83b241611bda3d1003d833c9ebc13cb96bc296ef93c81ad163cb702c3bd8dc805bdc33debbc47d466bcaeb742bd848becbc327506bd39c22dbdd59b42bd4ddb20bdad6724bd44dc04bd423b6c3b7c5aa93cefdfecbb9fdab0bdcaba69bdf988c9bb8e1456bc565a953de03a67bc9481df3c7afce13c09af0ebd5e170e3d634f1bbca975a5bbd79aadbb35e5efbce4c9a0bd5b91e83ca1a086bd179f3d3c663216ba326c393dbb04c2ba2170813ddf8c573b27fed63b2b678cbc3642f4bcfa494a3dfce69d3c92528c3d79479b3ca78663bdc0dbe4bcefe8523cf70f543a44cd15bdfc278f3da86f5ebc490128bd68f3053d34886d3db5fc923c5534f5bc9290e93c7ff59fbd83d21bbd89ae11bc952053bcd933be3c865d5bbd68795c3d40d16f3a99974b3da513cb3ce15aefbcbee862bde1ffefbd229de8bc1afb18bd5fadccbce26e373c0e739b3c9280643dbbe1253dfca736bd684d4abd5c261f3d01db89bcc31a4ebcf543823d9a74dfbc77ebb9bb8c3211bd2982803d2ff6133acb4fb0bc056b033b9a087ebd1d281c3d6ad6a6bc02b7033c1ac2a9baca3844bdf24868bdccbe973c74a604bb0afe6dbd385bb93bcd0c073cff5f36bd8d4ca43c25b8403c4e8f1fbd40ef4a3d66e41fbd61cf9e3ce05b24bd5f121e3ca763c7bc07d8313db3c5113c83e13a3c0a95f23d7e10a0bd5076ffba48a7c2bd6a6427bdc20a093d9d800dbd668e68bbc4d206bc232b89bbec08dbbcd0142fbcc06f343dd9dd48bdb10e2bbd70c3893dfe1593bc5ad2423c511af73cf32841bde80aba3caaef86bc4ae2243d63659bbc425b7d3c50fe9abd2f2b0cbda15edb3bc77fcc3ce3327d3c22a9a43c8a0aee3c66dc833d5d1d98bd2d73b93c04b842bd28b55c3c66849abc1da19dbdcca647bd2a05fc3c0984413ce1387c3ca47f2bbc231aedbdb8cf86bc3310a0bc0d9515bb348986bd18e034bd4aee1abd4213463b6dd236bc98e6b03de096573da1bdee3b4cb04fbc2cb837bd40ba8cbde217a93db9115ebd3067273db3b323bd1416f0bcb6219d3d7abc033ddc9978bd4211073bdc32453ced29403d326d0abd81a125bcf73d16bba646453c831bbabcb949a33c75bd18bd7ebb6abc63d0cfbc571c4e3d9398303c646cde3d156a923c2dc19ebddf6af9bb1b0f043d77cf11bda90d66bde1fb2b3cf9468ebc6aa92f3ce76b863d2e6815bdc7e184bd9591683cd2b4f5bc74f8523dd3f7893cfc3892bd7b11b23c634463bdc53045bd80df073c1f5ec9bc60632e3c4deb643d20a212bdd7de8c3b4e54263c49af023dff2c38bdb24155bcbd18d43dd5ea06bde0423fbcb332403e98fb66bd173e33bd2a5a603d6f53c13c426fc7bc2ca00d3d0863343dbb34e8bcad0d4e3dd2233abd3641b8bd4b80dcb90f2795bd067b33bcd00975bc6b49d13c9f0bd13ce4bf2f3df1e497bc04c64ebdc7df08bc32ba393d88d0d13b26d055bdd68c15bdc21a373d9cc02c3cf72f04bd009165bce9bd6f3db6da9a3b9f6dc83dae4510bdcbc9b8bc78628f3cce3443bd855859bcf986863c0b3f043d24098d3d50eea63ca405b83c942c083e22ce7c3d9c805abc0ef226bd5d2cb7bce0cdc0bcefe4133c546b9f3c32eff63c0c613138494ca63bd1a249bc741def3c63e6d8bbcf66273dd448373d70e6e0bbb3d693bd6fb5c9bc3e62ffbc76c65c3cee3f8ebd1c724abd054e78bd15c6d43c49cecabae0243ebcb6b4c93c7826c73c3d9819bd2b6ded3cbf2e983ab74f7c3d9dab693c1c129e3d774a9c3ba67d353d0947e1bcec8d453de80724bb228e883ca266fcbbf0f314bd07f46ebb8bf062bd6eaca3bcdab9bfb93acf88bdc5ce6ebc40d0d23b98c1603d93ae86bc9272ac3cc110febcd6560e3d084e8abd94d2183d129188bded8a953ca638c4bc174054bc6dd23b3c450e13bc488d4f3d8718cbbc8860973d9181afbde34469bb0e0f27bd636acd3bff1860bd167969bc871b96bc418b983db8c8c7bcc720c13cdafcaabc88640f3d5acb863b46c722bcacb5e5bd26d5a3bc5a84053d71f3fa3ab51eeebd75c0ba3d4ce4633c7cf1b5bdc5f2a0bcd337a0bc	w600k_mbf	52.42	0.9968	2026-10-14 19:47:13.752275+05:30
10	1	\\x786a02bce8a360bd39bc8a3ccdc6033e6c942dbdb24a283d07639abdc8fd98bd0fab8ebdacb5ddbbade6933db95d103d45f2843b3675583d0a795a3b710b13bd4155b83da8a18fbd22f0a93d2e2cfa3cbe173e3d371d9e3bac80693da15417bcc97137bd37048a3cc7b60a3d32f761bc035785bda056b83c96005d3c4c7fa5bc49af9cbc019cd5bdf537a93da971363d9393b03da0d425bd93124ebce07ba63d9cec7d3d489e8ebd2241ad3ca0a31d3c8066503c923aa53cd90b423d3e752cbd0261463d16a69e3d6d35973ccf0cb43db82ef0bcedf2433d99109cbc181974ba1cccf73cd9a0b0bcbfb086bd3425ff3c4310723ca09079bbc3c8453d18d79abd885ce9bc8083d1bd5d6dc93cbbed343c6a138f3c749a173dd77addbdfcce90bc579e883ce131afbcb33a4fbdfd0f2d3cf29008bd0414c13ae0f6acbc54720dbde5ce4c3c8ea5853c730b403d8e33d33c70f6dd3bebcf643cc993cb3ba28b183d319486bdf7990abdedf6edbdafad1a3d834ea53cad8c853b10cfefbca9d9e43d3515b43b8b69013d132d913cf61aa13de5870fbb924d5f3d2cda713c76f118bda83fa0bc52ef9dbd33bf0ebc9e6054bc38c1e8ba236534bc31df63bd154562bd8d5eee3c774a473d96bf8dbc8998a83c84b87e3c94d254bd1448353deb04603b6cc1fabc1725a33df895d33c15b88bbd63fc85bd50f6e23cb9478b3c8580b5bc8a0e043c7553703b7099123d9cbc373daa18123c140b423a7f6ad83c2348093d5595163d27b3693c55051d3d47e4193ddcec8fbd7fb8b5ba798fb93cc3eb3f3d4f25f1bccd8e40bd779217bbd45078bcb9d357bd3fe081bdd346cdbc4310fbbb9ca899bc457f0ebd177350bd51afb9bdc027773c0d7db03bbc8e1fbd235e04bb4a14593df6c21d3d00a632bdd051c7bc4caa993cac437bbb33407abc8aad983c984401bdf1a19b3d4f0c9c3c8c169ebc3828d9ba6c4aaf3dba63b0bb4a82e1bca50122bd44cfe3bc2e14e83c457604bec847dc3cf79d273ddc31313de826eabc446db43c5e65ec3c1c68973c53f7083de87d5dbcf333fd3c401fbf3c14bc59bdd4b9b43caa8da3bdd6d7b23cc76059bbf3049abcab4464bd57107c3d9d9be4bc9b88ffbc2f266f3c5c183c3d7c48a43ce97f38bd114a363d7e4746bd74d5e3bc17ca43bd1c37693df3aa893c67d0acbd049d8c3ca5a137bbba23153d86f1df3de7a1073df0478ebc5629f6bd68c54c3db07253bddd45bebc6d803f3d28d7603d12955b3c175f693c3de331bde0e3bcbcc518f4bb024e0f3d2543853caf69813d3656003d351b533b7fb38ebd14c185bbb3013b3d391920bda9b8c3ba5cd375bd3390e03c88afc8bc40ffaf3c8fc4c3bc00976fbdc250e7bc36e18d3d87e8e9bc6695d0bbdbe51ebd463577bbaacaa3bd375860bc23900c3c712c09bddf62f53c697760bd46c7ce3c11b118bd09f8f63a0fa04dbdeb3bb03d64dbedbcb7503fbd3655113e4084a3bdd610f6bcee617bbd9e654fbd7f51763d0955b0bd672b68bc9d84c2bc6655d6bc75715dbdb057223cb1af393d45de8fbc6e6849bd206a383dd2df36bc5d610f3d0b129a3d8af8f8bb57f9ea39e0d830bde810243d41d63ebdb17f5c3b29373ebd9b38e1bc40562bbd6e1f78bcbe8fadba45109b3deef235bc4d9a333d9c32b8bb6a07683d4d6891bc44ce87bc188d53bdfd8187bdccf702bc1a916c3db21e9a3d621d15bb16ff803dae0887bd79620b3ca64e6abdf4d41cbb01ef75bdaaa68d3c7b2f9f3c87d80a3d460809bda533423c95aa713d552372bb02dab4bc9d656dbd8423ba3bb236f93bfcb60bbcde029c3de7f1d9ba9cf139bde9759a3d58a9263ddbb2b2bd2d3d29bdded681bc4ee214bd5304f1bbc15e7c3cd15a17bc35e4623c41258d3c72b085bcdf7f033dde4a19bd5ea92c3d22d0153c61cd023d759e183daf477abcce976c3b4991c93c5c6d113dc0004aba6c7f3c3b1bcd9a3caaeb873cd5b409bd689d313d5534c4bc8cae8ebd7ee406bc80af9abc3a89323d982d5e3ca16d1bbd8b91aabccdeebf3c63f6aabcab87d7bc7470d1bc1e0c89bb5b4353b9c447bf3b56f7f63c7f3478bb682145bca80ff3bc69eeaabc39c65a3d25852abbcee986bc2cfdcf3df00e8dbc74bd363c730ea73ccbb369bc7feb2abd66e3413c726a9a3d76dfa8bdcbb2523d325b343c0c8f8fbd14dded3ce9b1d9bc6360dfbc4d793a3db82e593d814f133d0417b53d6d6f0cbd4bd4abbd428b02bc708b7f3df1e808bcc36a8cbcf986e7bb23da00bb66a05b3d2a14433d0f2ec33c44f912bd730beabc5347a03d3d7cc9bcd84c75bcfe2b95bcb407adbb030185bc9053163d202831bbd46f5e3d00d2683d6b41373d1699293d04577a3d885df7bcb98397bd960107bc6ada883b3c0d60bbc9f6b93c2057df3cea6d1b3d397e753d1ef80abd24dc663cccbd723a48c287baf71c91bc85e6423c4eaf03bdb7f6a93a735c6dbc5e5daa3d5d7215bd1b94c3bce46be4bd711d4f3d1af4bb3cd5d6dbbbaded863d25ee68bc13e682bd221e863d6a4f783d905b153d6138b5bcdc51ed3b3ecd2c3c232cbf3da4bd78ba29c38f3d68ded5bcb61f6e3d2ab973bcb9def1bcca4e88399ef381bd0b024abcdaef893c630141bdcc9691bd6a52d43c91427f3c107aea3c7f83873c2290a4bda16a4abc966d9bbd000f273d1d88cabd2ee3f138497285bb6dc784bcf1b16c3cdb9529bd3c59133db1a4fe3921b61d3d8e2ba3bd1e128bbd87fd12bdfe752a3c1355353b7fd133bc2c2ec1bc01e1ca3dac99b4bc6d3dd43aa12c6f3b0b53913d68ef02bcaa8449bdc34f67bd9e1501bdc19db43c9545943c840c25beefd2903c28f8beba1b5aaabdd57ce9bc5bcf6d3c	w600k_mbf	71.5	0.9821	2026-10-14 19:47:13.752275+05:30
11	1	\\x0efda0bdd9d3c3bc8fc0a73d2870733dfb74483d88add6bcf53b0a3ca91e7fbdcb14bebc471d12bddf95d03c2b7f5d3dbbdf52bbb3615a3d8247703dfc5becbda364ff3dc0e27ebd4be9453dc3c63abc7a34a93d7b2eabbb58c8153c0aaf483de9951ebdedc0a5bc489447bb5b05ebbb8c6f54bd7b8f0bbd03ca223ca7054d3b381dc73b2d61063d7711dc3b4eb40c3a8a6cb13dd24b6cbd6578ed3c8b524f3d4a26a3bc5fd983bd5965263c0388a43daf2d783d3eabde3c4374373d4d2a00bc56ca8d3d5528453dca56bbbc0d8d2e3dba67553cdeee99bc8d1dd7bdbe38cbbc67d70dbd950ec13c431813bdf115c73a7ce281bd91e0a73d1818203d1a9785bdd66bbb3c657f78bdce76c23d33c8483d63f23abd5d166c3c50a89abdc4b187bb3c23cabb31bb3b3c9f7953bda27b45bc6ea4cf3c3d82663c54fdddbdaffdb83c478d523c3d9441bcd543c53ca6566fbd79ce84bc9e5b15bddee9bebcddca293d5af42ebd71d094bcc949a8bdf687893bd6772a3d40ee5b3cbc4baebcc864063d89d98bbdc7d4f13c13ac34bc4088753dc5f146bda63c80bda956c3bcf0bab5bd602f373d167219bbe8a2afbd45ef57bc96a43cbcfbc5953d95bdcfbc62bc5ebdf8d4c33da3081dbdb083563dbae5e03b7a53193ddba313bda76c9b3bf3a5823dc047cd3a2a39cdbcb054403d3d9e6dbc3ae226bdce7bcebc94f4153c35450fbd0b0f913d2b0e0c3d2c5c9bbd47286cbdeba729bca2d54dbc5f86ec3ce53c823c51cff83ccc1d16bd28b3a53cca333bbd2d56453d31197c3dd52f92bdce56ff3b052d36bba4e938bc1e2b3e3c1aa9723c9bf710bd4894c43b31a3483dc27d043ba66cf03ced1e73bce8a063bdad73a4bc4eec8cbcc29585bdba9d0abd3fde9fbc5bf1c5b97bf6d03d39c409bd94e9e6bcc9f77f3cc24989bc0204f03ce507453d695908bccfef2b3bdeca93bcb5e713bd063d5b3d801d8ebd1a51ecbcc3c31e3df2755d3dea94a0bd1462e13ca538a53b01f8173b8ca9f33c62fcf5bc467f1b3d7f0c3d3c6a66ab3d02284abc7e4c9bbc7f2ba0bc8ac702bde1ba993d6bc554bd94118a3d34dba0bd77ad6bbd24c84d3c6584a83c30273b3cb913b73bcd38e3bc3050d73b955d473d3d51c63d6abaa0bc82bbd93cdfa9993c995ae0bc4b102a3db16a5a3cb3a045bd9921acbbc14b3bbd7f308e3d64678cbcd67fd3bb094e433d4645983cda3e8a3cbea4b4bdf6ab99bcbd39393c0f0330bd5146e83c2dee2d3dbc96ac3ca228f53b74e8cfbd0954bfbc9fbaac3c8745623c3c16c2bc625e133de668523b7393b6bc1e91a0bcf8174e3ced277e3cd887393d53daf83c2dffbebc551060bc685d57391ae925bc39da373d29ac1bbdeee367bd4840d43dfbaf8fbc84e689bd2246e73be30c9d3c83117dbd521a08bd00c2f83b3de5cf3c92f76c3d8b9a0fbda12d413d80adebbc382ab43a5197303bc2aaff3a8fa40b3c88b86cbde9d6873d96547fbcae6d533c0113c8bd622cf03c026d4dbd9495dd3b7a8398bb3ad7de3b2498333b3a355cbdea95f63c4e2c00bd6375a4bc6f1476bc30e1ea3cb39120bda5f819bc0565103d24f624bd14ae6fbd7ada933dff78553db29efcbcc9834ebdafc14dbdb2d10bbcc8c48dbc84e7ab3b89d5c33a298435bd748e62bcf49f803d16ec953dfd3d8e3ca172423d1057293c5d168cbd9fa5e9bccbb792bdab0d8c3b5440403db5dd503d35588c3c5036a8bd0ec29bbab1358f3cd97c8dbdfd1e023cdfc3a1bd87a456bd5e69503d5e4b82bd774e4a3d848282bdf1c3103d4c7357bd97cf423bb69e5e3c0f42053de3699a3c382bf5bb24ec0ebdc428debb4fd7c83c6146003c6e5fadbd35dd05bc118bd83bfd3e1f3db883adbcdce6473d9e906dbdb375fe3c148228ba8e49853de25e9c3cddb20ebde7e411bd711b5f3dae07153c702f073d934160bda52db5bcaf23963c2a478f3dfe0138bc77cf873cc72c21bd6515f3bc16cb45bc47ec163dce4c88bdf1bbadba262dd8bc4b64adbd63735d3de2b6bdbc98f78bbd56b872bd915d6bbc5dd38bbd411093bcb4f240bc7063d33beacc163dd8e331bb61b8fa3cf8c605bd0f1b2ebc59dc2abc333143bccf59993d1c74633d3b253bbdca21fe3da80829bdd72b85bd13057b3dc9c29abb7127573df36a25ba84a473bda4eedcbd6066263d9d361bbcfe88ca3baa328cbd3821acbbfd16dc3cc11942bc7747103c9d26df3cca0cbabc5d7ab33ce2f1293d0d6d54bdc5e25ebda2c307bbaafa9ebcd48ba6bc6e1993bb00420d3a97aaa5bc7ba64bbb1adfa7bc4c98f33ca4ebb43d657492bc77a690bbef0f613cb94e91bdaea0b43d8159f1bce6c1c13ca9c602bd5aa8b13c6122643c302f0f3de273513de667293d44f7c53c45b890bcf1f386bd5f40b13bbd534bbb04f9debc98a6fc3b18789dbc1b4ffa3af63698bc795f073de001a83d0ea4f83c9469dc3dc53584bb2832a13d870f213c198f65bd280960bdb3a27e3c508fa43c4f1cd0bd1b83ce3b34b50fbdfe0d3bbc7bc3adbcdcd781bda66f743d3f97973dbf568f3d0d33c0ba5eaf7c3dedbdf6bd174dce3df12c1a3da104f8bba396c0bcac63953cbe6917bc4c8e6fbd2e7590bc859e8dbd7f6d6ebd8ca687bb0e272b3d62bd1f3e0ff5b4bc33d9183c6138863c58959f3caafa7f3d5cabc93b6b84413df4c0693cf0e118bddaa617bcc77fdbbc02d27dbca02f3e3ceaf2aabcffb3fbbc760b013ddcd7073d014087bdf6b9ae3c35e33cbd3680493d52bb203b2b3414bda1336ebc122b10bd6970d3baae060d3d2a96093c512b263c0649cfbc864ece3b192866bd471c8abd1d8c353da51f683b859ba3bdbedfd7bced37b8bceea54abde745b5bdc6ec003d	w600k_mbf	77.73	0.9811	2026-10-14 19:47:13.752275+05:30
12	1	\\x67139abc26b0843a371660bc47b4403d40fed3bc65bb7ebd45dde4bbc89583bd28e6e13c0796333d8a76973de2aff13ca6e3973c22547cbc0317573c7de11abd8d19c43d973feabb9dad7c3dfc028d3de098173d7e08c6bdd02f083d757b943d0c9ac3bc1842c13bd20a9a3db0a08abd5beae3bbd33c443d12c69f3b5e229bbc528943bd53dd43bc5f076f3c33c242bda70cd03d164009bc4a59c5bb64ad223de31082bd996953bd59971dbd4cd9e13a0189613db2e9103c1b744a3d0641833cbd5ce13c8173ce3b2fc8d83c2808913b5f0de9bbc8f2e73cc6e8b1bc6db724bc5f1f253d9a8af63cd9e20cbd857d153d09f35ebd2a6508bd24ff953c621235bd10f1e1bc26d5d2bd8bb3bebc047f5d3d47c008bdde65c4bc66ac85bdf01c133d470d123dc9b2333dde6a943c49482b3ce88757bde38658bc58c811bd7de66cbd3ea1a8bce90231bd90ce07bd0fa61c3d279fa03c876900bd36703dbd9183c13c615799bd366bf0bbb988d6bdd12a753c55ef293d804273bcb7054cbd56d2c43d4acfa1bd1033b13db139763de8f9913dcb10143de711713cdecfbf3ccda480bc82e6f4bb2006bcbc103507bdda6f3d3c4ba21f3d5954433d37df353bd55c9b3dfbad0e3d4729233c12cdaf3b2cf8cc3c23fc043ddecdda3b34a0e43c264a7a3d7c77a63db7af2f3d7b2a3d3ca97dcb3c8807e43b5cbd963df6b84f3d982297bdd724843db862f13af6fe88bc36c2213ddb488e3df7e9ffbc3e4113bdf2b2ec3ad518ea3dd2426d3c747d343d13970dbcd9d254bd919c1a3dfb1c08bca6d3bb3c55ebb4bcf04e90bd57bf183d573706bdec1f57bc264d213b49e3fc3bafff253d813cb0bca08281bcf67f703c6c95f03bdc4a083b09e715bd390accbc1f752dbd5b3024bdf6eb683cde5d24bd701752bdfbbe5139237498bc363827bd7edd873c97e78abd340bc1bcd1a7883d1391c23c744ff73c110789bab08f2cbd34e2eebc512f02bdac96c0bdee1d08bc5691ccbd981ca6bcd741a8bcf310c73ce688a23c2ec6363da20765bdc9e2303c2e440b3c4c3e2abd9352a63b2c77333c539f8d3c9b3d093da797c2bd66db523c65856a3ce7c1fabcd96394bd09d0a93d1500713c31840a3d23e11bbd5a82cb3c0e1c8fbddd1f17bdbdb505bca30994bc4446c53d5c76e0bb8fac8a3d25a5463c0d7045bd3ecddf3db6b102bd393766bd7e93bd3dfaae5a3d40a53bbde55c50bd0e8c2fbda8465cbd0adaa1bbd30bd23d97ef65bc6da5b53c8aa9b53c379185bd7039ffbcd0b05b3dda0f413d02bfcf3bd6df623d87bf313d3c86c7bdf78cadbde510b6bbea108a3d112c8dbb08bc8e3c1ef1a7bd432528bd59a8c93c93a7cfbc8cdb15bd7746edbca38a4ebcc6c05d3c7723a43c7580cfbcadae813cf39c0bbd8ae44fbd835f27bd65546abd5132803cd75195bb94e236bc054f803bcd8d8fbddee5dabbf72c26bd98ecf03c43be3d3d905a81bcb685ad3c56e4bcbd7d96f13c661f84bde98a95bd72f2acbc21cda63c7b6b4a3cc9caa4bb7d2971bc7e39f6bc983b693dd0b6b5bb36ba533d85aa71bc0ee3603dcfd5ae3c314db33ca41050bcaebabf3c92c0843cb3826c3da6a20f3d219b1cbc6a788f3d92ed8cbdbf451fbc15b5c7bb7142273db91485bda429bc3c8fecf93ce27a573d82ec8cbd3a645fb8b287c23cd9284cbacd1b41bd5804a3bd529a8cbdfaaa983c09a88a3c326f163d2dafa23bccf35fbdecadc33bf09e783d89159bbcfaee7abd6807053c19d98abdb2d6873b11c34e3bd117e43c88a64c3b6ae38ebb95d65ebd3bd674bd7a6e883c0701313d00396ebde5471c3d1ed316bddd3e08bd3fec983c5fbb813def17eabd8763373d11ef0a3dcf737abde46548bddfef80bcfc5b89bd52f2d538f049cdbc29e6c63bd2d50dbb37f981bd139a30bc15ed1abbb01799bd06da863d8dd749bcc4d5ddbcbb22273d01b6ab39445cd4bde48718bd6d81db3cc599093d970148bc7c3a533c662a82bd41bf61bdf5aceabb05529cbcb8c6ee3dcf3881bb4b8ba4bdd2bd07bd9170f7bc81dd6ebc337630bdc0db02bd2cc797bcd1b5cf3cd0a901bdeb7e013cd2148bbdf1de0bbcf899ebbc7e9292bdbf17d63c008014bd72c49abbd142053e83370dbbf5050ebdad09c13ca2178cbb1a70803c3890b93cead5cc3c11a5e9bcef5f6e3caa5739bc58f1613d278469bcaa97dfbce89952bb0476aa3cb93ea13c108fd7bccb76813cd8ac8d3b3e2e3dbd92e36b3cd2e08b3bc83ababc0927223d77829cbc4a98013d1993fc3b79094abb133c20bcbe6305bc7cb9953d1115a8bb2af5fabcf89c7cbd494a013de83488bd3241c4bde4a722bdfac5ad3ca1c410bdb3dec83c8acb503cd3ee903d5feea73d36cb9ebca04b3bbba5fee1bce951c0bd579f643dbca4e93c74519a3ceca921bc3c2909bdf7f287bcd8ca193d8e98283de489ed3c8b3745bc484c80bc2d0b70bd00041bbcda73673d2607ec3c4339ccbc3bb794bb5655d8bc987060bc34ea263dfefa49bd950c4e3d101c98bc420dd3bcfd4ce03c91c9833c4fc7233adc0ed8bc7d0aef3d66f9acbb89133c3d96a3e53cc375483d6d759abc80439f3c934e04bcaf5eccbc51a62fbc7b1deebc76c3f83c71f22b3c34dbb73d8e02123d4ec0973df398313c5f03a0bc932da9bd3c1a45bd4f19323de3e982bdeb62bc3dcb3cc8bdf8ecb4bc7d51ebbb517682bcdd96023d905073bd299e973de9b140bbd5277e3deb13dfbddb1baabd3fdda43cb1db1c3dfe8a3dbdb2f992bcada684bc6bea453dece12bbda9c1463c2dd76a3d6811663c5a52a5bad54fa23cd05899bdafe109bdcf84163d4a0d5b3ceecd13bd18077abc10847cbde364cdbd479fa13c8a8e853d	w600k_mbf	190.51	0.997	2026-10-14 19:47:13.752275+05:30
13	1	\\xc34038bd6c7911bd2966aebce7caa73d3849323d25b622bb480514bdb7f22fbd8a35f5ba298ab0bc211d933d867446bc2482a4bcff4f74bd05bc0abc55cc693a9ee7513d4cd468bda96ab23da5821a3d42dc4e3d55e5dabc20228a3cdb13443dc17822bd598afe3b08839b3d9025b2ba054353bdb42a253d52e050bd57cefdbcf9f035bc60da1dbd53c9cfbbcf14183c0658603db3a916bd583c303c376bd83cf507183b18337dbd323881bc7fe0cd3cf5f6063dd19da5bc72561d3d80e953bdfdddf73cffc93ebcc6fcb33c2f4796bb2d25673cbe6d8e3df0c316bd58538b3cbaea6eb7a3501e3daf74a5bcca088b3dada792bd422f1e3c666db6bcc88e50bdf3c493bdd13802be6c0c843b3201e53c14ce32bd0c6f453d149a86bde1a0343c1836cb3dd9b3a83cba0f273c67d59dbbdd4330bdd6f6f2bc39a721bd36b8a6bd982e35bddd4e10bc2f09f4bc0605dcbb28eb12bcb2d30dbd64d489bcbffd00bd6d002cbd250590bc95a8a5bdcf74a73c50db213d3e3b2abdec457bbd75c9883d8ae85dbd9508523d75def73c0985823d2d81333d7007b73c927d8b3b0bacdebca9afb23ccc3265bc80362ebcfe83933a3bc302bd8a1ff0bc43622fbdbffd983cbcdc273dbe418f3c0dca3ebc69052abda6c9103dc2e897bc7141523de47d9d3c254ba13d41d0bb3cd1444c3dd0d53abc1465cabc8ca84f3dc6b6473d23dea1bd1541403d9dbfd23c41f7a03b875d7a3d443f8c3dd5e017bd5d25263d119731bd40d6e53dcb10ef3c385898bc11e989bcd8748cbdbd63863c98202a3cd170373d441269bd95193dbdc3b39a3cbfa7aabcefb2633c44375e3c7c27953bc7672a3d026de23cb3ed563c47c95ab9c0ecc43c4b2342bbe678adbcc9025fbdf3aa34bd5ab1f2bcebc3513d384f38bd12e69fbcd760333ce3cb943cfe78a1bc47187d3c7a62adbddaa5b2bbf61bc63dc17b1c3ddc50d1bb63e9833c1df1463c677cbdbcf77ba2bd025d59bdf3d6fc3c4daf79bdbbb30b39ddf862bd59bb243d652ac93cde6fde3deab599bd4103553de348ea3b65750abc97c5863aa5bf473d877bf5bcf157903d705603bdf319813b6890323d038608bdca5ea4bd23a2873d880e2d3d0a7ad6bc9042a1bdc240113d6c2f2b3ab999753c06ff68bc2d5684bd7168e23c77de1c3d9130c03c340eb1bbe379dfbdb8d0a73d408f88bdcf273ebceab8e43d9b47173d71b2b9bcda8735bda9b5e6bc42f987bd633f7a3b3fdd993d7e8ca13b2de36e3cc30aa4bcd181adbdc964a8bcec8a46bc73d68e3daa77dcbc2ce5523d079ca83d686d40bd16bf42bd9d455ebc8d658abad17e283d955d923c82fad5bdb8a008bddea5053df40f32bd5bde01bd7075eabc761470bb06c48d3c941131bd667f38bcd82e8bbcaed755bdc9365dbd494c5cbd9e9060bd952bf8bce081943c2990f6bc4b5c36bcb26fb8bc1a49793cd4804abc4242083dca5ea03caa7d76bdd069833d93aac3bd9d7dcb3c7bb345bda151fbbbe7494ebcca7297bad0e2b73aae839bbc67ec72b5730ea2bd30927d3d654c243ced842f3cdc68833cefb00e3d5da8e53c5850b83c5e2e5bbc6030623cf4c2923c83971a3ddd8908bc204303397152173d245f4abdf9f6923ccb42da3b801ab9bc5e4b95bc80bf373d580ebd3b9f46413db858f0bcfa0c1abd972d793de3edc63c2dfd61bde7d541bdaeb918bb07fc2e3d97434d3d9948233dd61a8cba575ca2bdaed0343d4585323d6f8cb8bd4d9075bd3dd564bcdb1b49bc7d255fbb86b74fbc4427283daa6f2c3df31e0b3d4f18a8bd2ef74abd5fa6063d14124d3d62575abdc06a003d85f02fbd6bc289bd2ed5753d2a5eef3c796af9bd342e353df4e5343da641d2bd1c9b04bd41d5803d2ee7e1bc6ebe063d64d9ecbc7d26a2bc1c4afcbcee3569bcdbe1e23ba7e1a4bb5d091cbd03df8a3de5cd923d46ca993ca580c73c1c420d3d1e1866bde66181bddf09233c0707453b638811bdc54c443c3709a7bc047dbfbd1b3c99bc942b98bcf1fec93d730ab73cd7cd5bbd9c78423cb07599bd75961f3ca46451bd80768abb32cf8ebc8a36853c104eacbcf38f4f3d49c76cbbe08106bd1e8104bdfad16ebd287e123d4129df3cdc1227bd0a90c43d105c573cc3f6163d789112bd4adcb0bc9b875dbcbd679d3c3a87923cbac2c0bdd2f13c3df19c803cf354143d3333023d5fba22bd72b574bd89e9863d98b2f9bb796fcc3c6f870b3dd2af29bdf3ad25bde6ac663ddc6a04bd5fa62f3d282fc1bb39fe12bd4d5f29bcfce500babb53323ddab9353d22fb10bd47b28d3d00768dbc3c8b3abd3ce008bdffab4f3d474905bd627546ba8a4186bca0687fbc5d9681bcd39b253c87f82d3df8f6523d3cd7033dfe8d49bd61a0f3bc1fd5fb3be8aa22bde920963c1f0c85bc3dc8213b2a18e73cce267dbd734d513ce24c223d20ae0c3d2198803dee9453bdbb41fa3c11f538bd75fd153d9ba2873d1154b73d7fb111bd44a9fabb8f903ebd8f27dc3cc2710d3d73756bbd3821173d1c1220bd4eaf60bd4cd2cfbcae65a13b3a9facbc2bb3aebc79d75e3d26030cbd4d4acc3dcf3848bb9a738d3dd96c73bd9cb3173c9a602fbd1ce6243d6c2e5c3c371a003c9825733d6ec10c3de161473d8175cdbc610aa13d6e3c803c5a45043dbf1690bd427f70bd0e52183d5f0d7dbd697e5a3c0d636cbdf7ef91bcc1684d3c0070aebc29669ebcc98e63bde99ce03c822d9dbb4f63c53dfaf91fbe7a6296bd4ef5133d3b0a143dfe40853c3a8e863bffdfa9ba0ea9153d4d465cbdabac653d78d8993df2dd143d9959bc3cf0b3d73abe467ebd251bb0bc4307273db7c1c7bc01bc53bd1651adbce9f310bc15a2fbbdc74292bcc09d913d	w600k_mbf	59.77	0.9963	2026-10-14 19:47:13.752275+05:30
14	1	\\x17440dbd7f82b83c6fe00abdce78473d75063bbc590ff6bce3fe61bd733ca3bd2f642ebd179654bc85b17c3c9a33033de6c378bc586d883c116e143d1a28ffbc77fa4e3d8b6390bd8096213de05bf33bf163e73ca996b6bd2a83193dae18a83d93cabcbad7f7ec3b9b03b13d1dcfdebbbb90d7bccc4223bd4b3497bbd4f6ccbb499d12bde135b5bc251d393d9a681fbc8a0b873daaaa20bc057738bc1c3eb13ddd95593de799c7bcde365ebde8e9b33cd4aa113d27c42cbcdb52e43c3bc6803c8bde033daa554b3d8bf87fbdad183d3dfc9aa3bc0cf29b3c6d459dbd7dfee4bcb1b5f4bb9513a5bc07eababd8c601c3c1e2188bdeb4c9abc2c19863c9c01b5bd93b1babbb0e582bd1c70d63bb514aa3dece68f3c4f4fa13c3685a2bd0fce973c0a3d07bc9191393bbc0d8dbb0a7a243dd15885bd4d6a503d78e718bdcf10e9bd6ccbcbbc8f65ce3c620fc53b941b4b3db7c71ebcd2b703bda06cde3b9d6f8b3d877366bd2248043d5106e9bdaa9eca3c676e623d664f43bce14391bd4433cb3d92a81a3c2872a1bc18151f3dba689b3d88db013da7e45b3d2447bcbdbb5080bc834982bc843517bd290fadbb5730bdbba158993d0669463d96cd47bdeca012bdb753543d7ab1053d883a53bc8b09923cf545cbbce4fd553c7b77e33bbaec253d6df3283de0e8483dc2afb23d5dace1bcb7254f3cd5ab393d9148a53c6882cabc033330bd51cdf13c6e84823c3123e63cf733023defed74bc2d0b1fbd49bd143d1f67843d2a8206bd97fbbbbc544ecf3b3cced7bd9e60b2bbe58947bdeee5f73b1c8befbc42d93dbd7f892b3acaa756bd4aea3abd6db343bd2878413d6f2017bc10912c3d52cc9ebc11ea70bdd6812dbbbcc165bd8d4f353caa3f11bdba8dd83c172d953dfa208b3dbebc03bdc2e7a1bdacee403d3d2adcba98cf98bb4be1d33b6b7135bda50e32bb4e814cbcc5665fbd781dfc3c6f1fb7bc2211d9bcac33153cd5a8c33b53e415bd40dd3a3d278be0bd1f98c73c5dbb6fbc75ae133d4b50c83c05f0bf3ccf62b83aca0cb23d985f1e3c00b084bcf5cdb93ca740903c66e63e3bff7c5e3d069363bd06763bbdaf3684bdb88a2bbdd2d944bc6960bb3ca1cf9abce240a8bc47c5e8bb3483353ce2d10c3de8fda2bba03b8e3d14ac0dbdc71ec63cb47bc63c1e7c893cce1782bc7bcd91bd211e373d45ad5dbd104ad4bb29b09e3d812d4d3d49eee4bc081575bd20593bbdb4b7a4bdb99a67bd70566f3da2de1f3dc837e23cfdedfc3839a4fabc42bf2fbbd695a23daf1bc13c40d3feba1a3dc83dbbfee63c3aad1fbd055ccfbd202f603cde52383cf44847bdae3620baec9c86bd441cde3c5cc517bdca3459bb3f47fdbbffa168bdbbc39cbc7d714f3c2200a0bc52496cbdb7f11e3d20f6453cbaed6cbd39561dbc3cabfdbc626061bdee410a3dab840ebd60ab00bd6fe707bc55df47bdf9e3d83c5c51373df334393d3f8a88bcefaea93d2e25c1bd6fb8beb9a7226ebd63cb1fbd2ab55b3aa63c22bdeacc213d9774b1bbc44954bcff80123cee33d03c7733913c0b7457bd2ff400bc80f6b53d3dc7f63ae13b453d2f7e4a3c0433e33c7b97ebbbb94e523dc07f8d3d969cc5bce83200bde44fb8bda22ecebcf08008bb4bcc3db95e8a943c51f62e3d856c7b3c50eeb53d819e11bc5c8f4c3bc72c17bd839babbc6404b8bda4bb00be005704bda57a313d94b994bb233b443c4574003df84eedbdbb2e293c2c57b8bc7bdd01bdd14cfebc755492bc61288fbdecbb713d43e728bc2323013a8a485f3dd92c583d97d9c0bd5e42c6bdbcc5e8bb7507213db2fce13c1df7bd3d257ca1bda46d11bd18e10d3d33e34b3ddc3f1dbd73c48cbcada438bd8334babb22158b3be18e90bc65846b3c69fe4e3df40e3dbc71be18bd5dc61abdedc313bd527513bdd0736c3d584c85bbe425873defc41bbd3a789abc5be431bc8454f2bc73d308bd1561d0bd95641bbdb8cbc8bb43fa883c7c79323c139a0fbd99fa6bbd6175dcbbde7d4ebdd69e913d04820f3c447542bdf4ee72bc521fddbc1f62e0bc7a179b3cf33f56bd916d4b3ce536963c486f90bc7f9d8a3de1fe56bd2e0c92bc402a35bb1225f4bc9cbfc03c049694bd79520fbd2d08173e6ff526bdb96734bdea31edbb0c5df33ba06ad83b152a05bdd8d7903c85b602bde3f9813cbf0886bdee58b7bcfa9f52bd3aefaabd6283813a48223b3d15e9a63c7520cdbc81712b3d853292bdbdc974bd97bc03b93254d33b1fbcea3ca64f3e3bac3204bdfa210c3de76e823c160b843b84064dbd3fdb183df35c3e3af86d7c3d4c7b9bbc0b85a5bc674e253c331e19bd44d080bca6fe033c8d0707bd9291343da9cd053d557b9bbca459da3dd495833c7637a3bdb2b8e7bb4ba437bde780f5bcf95a4d3d906c2a3dfe51ba3c98b66f3b4451b2bc416598bbfe471e3d80de0ebd7792733daa33ac3c17b905bd999a27bd0eae9bbb5866193c7a21273c8f3c4cbd7d81923c592d82bdd3fccabccd42fcbbc28c13bd3fba783caac1a73c2d1689bc4177673d89c295bc2bd00cbcf4f9bbbc5311a13d741613bcd5b3213d1f3005bb93b3e43d71186bbb1ac4333d2c3f6e3bc65cab3b4d0b2abdcf5163bda14fda3c0f0b4fbd6afe09bda46a43bc2f8f5bbcfadf2a3d520bc4bc65361dbd35a416bd7a75373d58db93bdde12883d3358a4bdba700d3d05c3d63b5f6abfbc932f643dcafdd5bc7fd3173d0a24c9b9a2334c3dca9807be68c2eabc5069e9bb58732e3da3d33bbdd855163d6727eeba70ab573db372babc1ff9883d0424b53aa8eb423de6c9113b173187bc0956b3bd7f3bbfbc8c94da3cf6848c3c21b5ccbdc7c5a13dfd7f54bd7bb8b8bd1cf3d9ba80fe073d	w600k_mbf	213.56	0.9032	2026-10-14 19:47:13.752275+05:30
15	1	\\x8b6cd9ba0fd811bd497e413d636bc73d358172bda81b23bda393d6b923cf8bbd3fd1d5bc337b64bb9ec6803dda3b0b3dbfbaa83c1c5b653def40d13c86b216bd2d14e73d7e741cbd6337893dc951663cb816973d5eed21bdced9163d421d6c3d4f7058bc68db153dfaa4653c30bf3f3ddfa616bdcda759bcecc433ba3b8e4dbd235db7bd1b51183b8f0c5c3c1f07c5ba0a8ad03d8a6982bdcb5a063dfd419e3dad21953cfe0053bd9efe163da32bd73ccf29293d30965dbc605f3e3d091a18bddb404137fbb8993df7db4e3d87087e3d2b0c8cbd957db2bc67d209bd571cb53cc5f3233da7f9b2bc8ce4ddbc8d3f8bbc766982bc96099fbcd3f4213d61ef90bd8b4d06bd5c2a80bd1625653c51822f3d4e023bbc4adb843d8ccaf9bd8d1410bdc3f98b3d38b8a9bca4be9dbc9d760ebd10aa2bbdbf12733c70966fbdb374243b9645433d5f8b0fbc09ae933b30f1583dae5cd83c98f5df3c5cbb153cf41c383da5d329bd6b0991bd727314be1a7cf83c9766cfbba6fa683c42b9a2bc1071ca3dd3629bbc8509583d8c7bc9bc9c145f3dcc44743ce720ff393bc0003d51ef45bca549813c819012bd8dde6dbd022322bd5621993c6e3c943b53d4b63bce853bbdccf0463d12e9383dcc5c2dbcbe3c4b3d2233dfbc8f4185bd931803bcd951b7bccde550bc0c71153d9918973ba0a7cbbcb956b6bc5856293ca854963c238c9cbd0945493d5a6d5f3c6b5c43bc54369dbb2759443c9b00a5bb3f165f3d9432003d6ee5783d1ce205bc76d7483c243ad5bb636b37bbcf27683c5001fdbc34e21e3cf2214cbd11688dbd6094b43cdf6528bd331f4abd8d04b1bb781903bdee3a0fbd39a8d73bbf66163d8c52483c43b41cbd95ef8b3b713702bde8f803bc569d0d3c39942a3c48f05b3dfaf8a0bd577ec4bc332aee3cf86263bd901834bca6c2ebbaffa972bc093b5c3c25f1e73aa097debc4f4e623d02d8e13c776c05bd785a823c6e4049bda84679bb8790c83c620acebcfedc863c56bb1f3c0333773d39644d3de159243dee35953be201ba3ad5ad8cbbdda93ebcd0263d3db950433cb80182bc0bd4d83cd8fd23bd3b2430bbaca66a3d9e3c403baca184bdbbafe23cf3155fbd33bc8abc0953e93c541e583c42fdc63cb7482dbd0f201cbc031180bd7986823dc140acbcb4a1713cc524dbbce5877abdb1cea63c15361c3c2aa821bc3b70cd3d508f1f3d1705723d3a838fbda3065d3b2a2e803cf6ec88bd7a50cd3cf159bd3ce1ab953dfe2d2c3d809719bd742974bcbbb23d3d65f7703c1d857dbb46aec73dc4819f3c6ab5993b35118dbd2e518d3c3753563c991fbebc3fb4403da8c839bd5bca943c5de505bd3ef6fd3c7a470e3b5f43c1bc281104bd6e7e213d3e470e3b3f6121bdac8b33bdaf7a35bd197311bdb5a290bdd73bb03b5bdc9bbb3716ba3cee4a33bdb4611c3ce7c973bd5b5f313c982c58bdb01e6d3df8430bbc94dad9bc2722be3d0134a3bd7112c1bce49facbd361e29bd6aee07bdce2cf4bcc0380fbd5f96ab3cbd7533bb5e7820bd3064da3c1a952c3dfd2d22bd365f9fbdf4d7933da369c9bc07b40b3d64d8ee3cc44a5c3b35bcf1bcc4b5f23c063d093d7a9e48bd0fdd1f3c35cab1bde0354dbc0c6703bd58e24f3dc7b315bcde40493db27bbbbcc78ab53d6e3bcdbc5ae9a13d28fd14bd91fcb5bc528184bd981ecebd1a5628ba499be33cbf94b63c4ad1433dd301893ca1ff44bd06ff31bdda41fabce3fc253db05bccbb5cdce53ca12db4bc4752433d2902b8bc1e1bec3c5776c33c57ac013dc1032fbd7ca423bc0a9706bdef7be73c7de89e3c72fb223d6f08943c75d7ffbcfa43ea3d937ca13d52f70abe189098bdc358963b1f5e64bd772f30bc928ee8bc1466a8bcc3b78f3b39f2ca3cbd61283dc646d3bcd75d4abd918ae2bb00e5ce3cb2342d3d0705563d4ca65cbd03de1cbcfbde74bc11afecbb0b61cfbcfaaf73bdf914cfbc98576abc7e6da3bb1596f93c61e195bd481367bd812b0c3d2d3478bdc5bb843d6400d03b464cd7bc07c724bcadddadbc4823d1bc6c49d5bca12d5bbd2328b9ba6379683d94cbc8bb56347c3c60d592bcab1a143d759c433cb43d77bd97e3b53d83251ebd82373e3dc358493e7e9584bdc50fc8bd6923f23d25e3a13a4e14293c6703a33c3272a03cfa52a7bde1bdd33c4c2ec4bb5bb85dbd17d9e63ce37062ba4cdac8bc5abd523c3187c8bc3dae9ebb0ec0163d254a303cabd7b8bc4bdc46bdd965c13c260090bc26365f3b0b718cbd26fea4b90c1f903b81fababc14bbbd3c4838da3c59eb0cbd8bcbab3da0dc9ebcd7c812bdecea203cd59084bcd3460fbd6c1e86bcaba18d3b6049403dadbfab3d3759333de97eaa3dea67263d144425bd2ba350bcf88336bdc80780bd692065bcdfc2133d2654aabcd6221b3ddd315f3df95341bd25ad853de7daa83c750e60bccbd9563cad4015bce43870bdd3cc423d4c9e08bdbf720f3df4c258bd2985823c21d17abdb4ca013c38657f3c7aaf62bd9b51583c2834e63a13990cbd1b734f3d5526103ba989a23d6bbb29bbd7926f3d40b3cebbd7e36a3d1c9ca63cadc56a3d35fc8dbc2bc7843d0a1b54bb6e85fbbcfd6f51bde9ce88bd03246fbc67ba93bc66eb253c383de3bb33376e3c5fbc043cb225943cf3e417bcb1a8123c43cbe3bb72c9f2ba7325af3d948581bd768cd0bb7d4735bccabe093d80d6b73ce9cf503c34cf483d918704bdef21813d1096aebdeaba51bd08af39bc2176933d2e99c4bd1bbb03bc2c1ff83cb4267a3d396272bdfabd533d45728739bff7c13d6f0608bcb8abeaba3ec382bd6757d1bd5646733dd5e228bce5d9fdbdb72fa23d1c902bbdaa12bfbdefaa2c3d72511d3d	w600k_mbf	29.3	0.9737	2026-10-14 19:47:13.752275+05:30
\.


--
-- Data for Name: holidays; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.holidays (id, holiday_date, name) FROM stdin;
1	2026-01-26	Republic Day
2	2026-05-01	May Day
3	2026-08-15	Independence Day
4	2026-10-02	Gandhi Jayanti
5	2026-10-20	Dussehra / Vijayadashami
6	2026-11-08	Diwali
\.


--
-- Data for Name: leave_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.leave_requests (id, employee_id, leave_type_id, start_date, end_date, days, reason, status, approved_by, decided_at, created_at) FROM stdin;
1	1	2	2026-10-14	2026-10-14	1	\N	APPROVED	admin	2026-10-14 19:49:41.671932+05:30	2026-10-14 19:49:40.045482+05:30
2	2	1	2026-10-15	2026-10-15	1	Personal family event	APPROVED	Admin	2026-10-10 11:00:00+05:30	2026-10-25 13:02:26.383722+05:30
\.


--
-- Data for Name: leave_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.leave_types (id, code, name, is_paid) FROM stdin;
1	CASUAL	Casual Leave	t
2	SICK	Sick Leave	t
3	EARNED	Earned Leave	t
4	UNPAID	Unpaid Leave	f
5	OTHER	Other	t
\.


--
-- Data for Name: offices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.offices (id, code, name) FROM stdin;
1	KADAP	Kadap Office
2	TIRUPATI	Tirupati Office
\.


--
-- Data for Name: payroll_adjustments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payroll_adjustments (id, payroll_record_id, type, description, amount, created_by, created_at) FROM stdin;
1	5	BONUS	Diwali Festival Bonus	5000.00	admin	2026-10-25 13:03:39.219179+05:30
\.


--
-- Data for Name: payroll_audit_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payroll_audit_log (id, payroll_period_id, payroll_record_id, action, actor, old_value, new_value, created_at) FROM stdin;
1	1	\N	PERIOD_CREATED	admin	null	{"year": 2026, "month": 10}	2026-10-25 12:58:46.897393+05:30
2	1	\N	CALCULATED	admin	null	{"created": 0, "updated": 0, "skipped_no_salary_profile": ["1234"], "employees": 0, "gross": 0.0, "deductions": 0.0, "net": 0.0, "overtime_pay": 0.0, "bonus": 0.0, "unpaid_leave_deduction": 0.0, "overtime_hours": 0}	2026-10-25 12:58:46.911513+05:30
3	1	\N	CALCULATED	admin	null	{"created": 5, "updated": 0, "skipped_no_salary_profile": [], "employees": 5, "gross": 400664.0, "deductions": 13654.0, "net": 387010.0, "overtime_pay": 11964.0, "bonus": 0.0, "unpaid_leave_deduction": 3654.0, "overtime_hours": 27.5}	2026-10-25 13:03:15.597453+05:30
4	1	5	ADJUSTMENT_ADDED	admin	null	{"type": "BONUS", "amount": 5000.0, "description": "Diwali Festival Bonus"}	2026-10-25 13:03:39.219179+05:30
5	1	\N	CALCULATED	admin	null	{"created": 0, "updated": 5, "skipped_no_salary_profile": [], "employees": 5, "gross": 405664.0, "deductions": 13654.0, "net": 392010.0, "overtime_pay": 11964.0, "bonus": 5000.0, "unpaid_leave_deduction": 3654.0, "overtime_hours": 27.5}	2026-10-25 13:07:15.09787+05:30
6	1	\N	APPROVED	admin	{"status": "CALCULATED"}	{"status": "APPROVED", "employees": 5, "gross": 405664.0, "deductions": 13654.0, "net": 392010.0, "overtime_pay": 11964.0, "bonus": 5000.0, "unpaid_leave_deduction": 3654.0, "overtime_hours": 27.5}	2026-10-25 13:09:36.817248+05:30
7	2	\N	PERIOD_CREATED	admin	null	{"year": 2026, "month": 9}	2026-10-25 13:09:50.864834+05:30
8	2	\N	CALCULATED	admin	null	{"created": 5, "updated": 0, "skipped_no_salary_profile": [], "employees": 5, "gross": 388700.0, "deductions": 398700.0, "net": -10000.0, "overtime_pay": 0.0, "bonus": 0.0, "unpaid_leave_deduction": 388700.0, "overtime_hours": 0.0}	2026-10-25 13:09:50.877848+05:30
9	2	\N	APPROVED	admin	{"status": "CALCULATED"}	{"status": "APPROVED", "employees": 5, "gross": 388700.0, "deductions": 398700.0, "net": -10000.0, "overtime_pay": 0.0, "bonus": 0.0, "unpaid_leave_deduction": 388700.0, "overtime_hours": 0.0}	2026-10-25 13:09:50.9124+05:30
10	2	\N	PROCESSED	admin	{"status": "APPROVED"}	{"status": "PROCESSED", "employees": 5, "gross": 388700.0, "deductions": 398700.0, "net": -10000.0, "overtime_pay": 0.0, "bonus": 0.0, "unpaid_leave_deduction": 388700.0, "overtime_hours": 0.0}	2026-10-25 13:09:50.928684+05:30
11	2	\N	PAID	admin	{"status": "PROCESSED"}	{"status": "PAID", "employees": 5, "gross": 388700.0, "deductions": 398700.0, "net": -10000.0, "overtime_pay": 0.0, "bonus": 0.0, "unpaid_leave_deduction": 388700.0, "overtime_hours": 0.0}	2026-10-25 13:09:50.944261+05:30
12	2	\N	CALCULATED	Admin	null	{"created": 0, "updated": 5, "skipped_no_salary_profile": [], "employees": 5, "gross": 405919.0, "deductions": 10000.0, "net": 395919.0, "overtime_pay": 17219.0, "bonus": 0.0, "unpaid_leave_deduction": 0.0, "overtime_hours": 39.6}	2026-10-25 13:10:50.8082+05:30
13	2	\N	APPROVED	Admin	{"status": "CALCULATED"}	{"status": "APPROVED", "employees": 5, "gross": 405919.0, "deductions": 10000.0, "net": 395919.0, "overtime_pay": 17219.0, "bonus": 0.0, "unpaid_leave_deduction": 0.0, "overtime_hours": 39.6}	2026-10-25 13:10:50.900011+05:30
14	2	\N	PROCESSED	Admin	{"status": "APPROVED"}	{"status": "PROCESSED", "employees": 5, "gross": 405919.0, "deductions": 10000.0, "net": 395919.0, "overtime_pay": 17219.0, "bonus": 0.0, "unpaid_leave_deduction": 0.0, "overtime_hours": 39.6}	2026-10-25 13:10:50.916604+05:30
15	2	\N	PAID	Admin	{"status": "PROCESSED"}	{"status": "PAID", "employees": 5, "gross": 405919.0, "deductions": 10000.0, "net": 395919.0, "overtime_pay": 17219.0, "bonus": 0.0, "unpaid_leave_deduction": 0.0, "overtime_hours": 39.6}	2026-10-25 13:10:50.934088+05:30
\.


--
-- Data for Name: payroll_periods; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payroll_periods (id, period_year, period_month, start_date, end_date, status, calculated_by, calculated_at, approved_by, approved_at, processed_by, processed_at, paid_at, created_at, updated_at) FROM stdin;
1	2026	10	2026-10-01	2026-10-31	APPROVED	admin	2026-10-25 13:07:15.133516+05:30	admin	2026-10-25 13:09:36.822821+05:30	\N	\N	\N	2026-10-25 12:58:46.897393+05:30	2026-10-25 13:09:36.817248+05:30
2	2026	9	2026-09-01	2026-09-30	PAID	Admin	2026-10-25 13:10:50.868881+05:30	Admin	2026-10-25 13:10:50.901114+05:30	Admin	2026-10-25 13:10:50.917738+05:30	2026-10-25 13:10:50.935203+05:30	2026-10-25 13:09:50.864834+05:30	2026-10-25 13:10:50.934088+05:30
\.


--
-- Data for Name: payroll_records; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payroll_records (id, payroll_period_id, employee_id, attendance_days, present_days, absent_days, half_days, leave_days, holiday_days, regular_hours, overtime_hours, late_count, early_checkout_count, missing_checkout_days, basic_salary, hra, allowances, bonus, overtime_pay, gross_salary, pf_deduction, esi_deduction, professional_tax, other_deductions, unpaid_leave_deduction, total_deductions, reimbursement, net_salary, breakdown, status, created_at, updated_at) FROM stdin;
1	1	2	25	18	0	0	1	6	146.27	5.5	4	0	0	48000.00	19200.00	14500.00	0.00	2475.00	84175.00	1800.00	0.00	200.00	0.00	0.00	2000.00	0.00	82175.00	{"fixed_monthly": 81700.0, "salary_divisor": 26.0, "divisor_basis": "profile", "deduction_base": "fixed_gross", "per_day_rate": 3142.3077, "lop_days": 0.0, "absent_days": 0, "half_days": 0, "unpaid_leave_days": 0, "paid_leave_days": 1, "pending_days": 6, "overtime_rate": 300.0, "overtime_multiplier": 1.5, "negative_net": false, "policy": {"week_off_days": [6], "full_day_min_hours": 6.0, "half_day_min_hours": 4.0, "overtime_threshold_minutes": 30, "early_checkout_threshold_minutes": 0, "missing_checkout_policy": "assume_required", "working_days_basis": "profile", "deduction_base": "fixed_gross", "deduct_absent_days": true, "half_day_deduction_factor": 0.5, "overtime_multiplier": 1.5, "pf_rate_percent": 12.0, "pf_wage_basis": "basic", "pf_wage_ceiling": 15000.0, "esi_rate_percent": 0.75, "esi_wage_basis": "gross", "esi_gross_ceiling": 21000.0, "rounding": "nearest_rupee"}}	APPROVED	2026-10-25 13:03:15.597453+05:30	2026-10-25 13:09:36.817248+05:30
2	1	3	25	19	0	0	0	6	154.53	5.5	4	0	0	45000.00	18000.00	13500.00	0.00	2310.00	78810.00	1800.00	0.00	200.00	0.00	0.00	2000.00	0.00	76810.00	{"fixed_monthly": 76500.0, "salary_divisor": 26.0, "divisor_basis": "profile", "deduction_base": "fixed_gross", "per_day_rate": 2942.3077, "lop_days": 0.0, "absent_days": 0, "half_days": 0, "unpaid_leave_days": 0, "paid_leave_days": 0, "pending_days": 6, "overtime_rate": 280.0, "overtime_multiplier": 1.5, "negative_net": false, "policy": {"week_off_days": [6], "full_day_min_hours": 6.0, "half_day_min_hours": 4.0, "overtime_threshold_minutes": 30, "early_checkout_threshold_minutes": 0, "missing_checkout_policy": "assume_required", "working_days_basis": "profile", "deduction_base": "fixed_gross", "deduct_absent_days": true, "half_day_deduction_factor": 0.5, "overtime_multiplier": 1.5, "pf_rate_percent": 12.0, "pf_wage_basis": "basic", "pf_wage_ceiling": 15000.0, "esi_rate_percent": 0.75, "esi_wage_basis": "gross", "esi_gross_ceiling": 21000.0, "rounding": "nearest_rupee"}}	APPROVED	2026-10-25 13:03:15.597453+05:30	2026-10-25 13:09:36.817248+05:30
3	1	4	25	19	0	0	0	6	154.53	5.5	4	0	0	38000.00	15200.00	11500.00	0.00	2063.00	66763.00	1800.00	0.00	200.00	0.00	0.00	2000.00	0.00	64763.00	{"fixed_monthly": 64700.0, "salary_divisor": 26.0, "divisor_basis": "profile", "deduction_base": "fixed_gross", "per_day_rate": 2488.4615, "lop_days": 0.0, "absent_days": 0, "half_days": 0, "unpaid_leave_days": 0, "paid_leave_days": 0, "pending_days": 6, "overtime_rate": 250.0, "overtime_multiplier": 1.5, "negative_net": false, "policy": {"week_off_days": [6], "full_day_min_hours": 6.0, "half_day_min_hours": 4.0, "overtime_threshold_minutes": 30, "early_checkout_threshold_minutes": 0, "missing_checkout_policy": "assume_required", "working_days_basis": "profile", "deduction_base": "fixed_gross", "deduct_absent_days": true, "half_day_deduction_factor": 0.5, "overtime_multiplier": 1.5, "pf_rate_percent": 12.0, "pf_wage_basis": "basic", "pf_wage_ceiling": 15000.0, "esi_rate_percent": 0.75, "esi_wage_basis": "gross", "esi_gross_ceiling": 21000.0, "rounding": "nearest_rupee"}}	APPROVED	2026-10-25 13:03:15.597453+05:30	2026-10-25 13:09:36.817248+05:30
4	1	5	25	19	0	0	0	6	154.53	5.5	19	0	0	42000.00	16800.00	12000.00	0.00	2228.00	73028.00	1800.00	0.00	200.00	0.00	0.00	2000.00	0.00	71028.00	{"fixed_monthly": 70800.0, "salary_divisor": 26.0, "divisor_basis": "profile", "deduction_base": "fixed_gross", "per_day_rate": 2723.0769, "lop_days": 0.0, "absent_days": 0, "half_days": 0, "unpaid_leave_days": 0, "paid_leave_days": 0, "pending_days": 6, "overtime_rate": 270.0, "overtime_multiplier": 1.5, "negative_net": false, "policy": {"week_off_days": [6], "full_day_min_hours": 6.0, "half_day_min_hours": 4.0, "overtime_threshold_minutes": 30, "early_checkout_threshold_minutes": 0, "missing_checkout_policy": "assume_required", "working_days_basis": "profile", "deduction_base": "fixed_gross", "deduct_absent_days": true, "half_day_deduction_factor": 0.5, "overtime_multiplier": 1.5, "pf_rate_percent": 12.0, "pf_wage_basis": "basic", "pf_wage_ceiling": 15000.0, "esi_rate_percent": 0.75, "esi_wage_basis": "gross", "esi_gross_ceiling": 21000.0, "rounding": "nearest_rupee"}}	APPROVED	2026-10-25 13:03:15.597453+05:30	2026-10-25 13:09:36.817248+05:30
5	1	1	25	18	1	0	0	6	146.27	5.5	5	0	0	55000.00	22000.00	18000.00	5000.00	2888.00	102888.00	1800.00	0.00	200.00	0.00	3654.00	5654.00	0.00	97234.00	{"fixed_monthly": 95000.0, "salary_divisor": 26.0, "divisor_basis": "profile", "deduction_base": "fixed_gross", "per_day_rate": 3653.8462, "lop_days": 1.0, "absent_days": 1, "half_days": 0, "unpaid_leave_days": 0, "paid_leave_days": 0, "pending_days": 6, "overtime_rate": 350.0, "overtime_multiplier": 1.5, "negative_net": false, "policy": {"week_off_days": [6], "full_day_min_hours": 6.0, "half_day_min_hours": 4.0, "overtime_threshold_minutes": 30, "early_checkout_threshold_minutes": 0, "missing_checkout_policy": "assume_required", "working_days_basis": "profile", "deduction_base": "fixed_gross", "deduct_absent_days": true, "half_day_deduction_factor": 0.5, "overtime_multiplier": 1.5, "pf_rate_percent": 12.0, "pf_wage_basis": "basic", "pf_wage_ceiling": 15000.0, "esi_rate_percent": 0.75, "esi_wage_basis": "gross", "esi_gross_ceiling": 21000.0, "rounding": "nearest_rupee"}}	APPROVED	2026-10-25 13:03:15.597453+05:30	2026-10-25 13:09:36.817248+05:30
7	2	3	26	26	0	0	0	4	211.58	7.92	4	0	0	45000.00	18000.00	13500.00	0.00	3325.00	79825.00	1800.00	0.00	200.00	0.00	0.00	2000.00	0.00	77825.00	{"fixed_monthly": 76500.0, "salary_divisor": 26.0, "divisor_basis": "profile", "deduction_base": "fixed_gross", "per_day_rate": 2942.3077, "lop_days": 0.0, "absent_days": 0, "half_days": 0, "unpaid_leave_days": 0, "paid_leave_days": 0, "pending_days": 0, "overtime_rate": 280.0, "overtime_multiplier": 1.5, "negative_net": false, "policy": {"week_off_days": [6], "full_day_min_hours": 6.0, "half_day_min_hours": 4.0, "overtime_threshold_minutes": 30, "early_checkout_threshold_minutes": 0, "missing_checkout_policy": "assume_required", "working_days_basis": "profile", "deduction_base": "fixed_gross", "deduct_absent_days": true, "half_day_deduction_factor": 0.5, "overtime_multiplier": 1.5, "pf_rate_percent": 12.0, "pf_wage_basis": "basic", "pf_wage_ceiling": 15000.0, "esi_rate_percent": 0.75, "esi_wage_basis": "gross", "esi_gross_ceiling": 21000.0, "rounding": "nearest_rupee"}}	PAID	2026-10-25 13:09:50.877848+05:30	2026-10-25 13:10:50.934088+05:30
6	2	2	26	26	0	0	0	4	211.58	7.92	4	0	0	48000.00	19200.00	14500.00	0.00	3563.00	85263.00	1800.00	0.00	200.00	0.00	0.00	2000.00	0.00	83263.00	{"fixed_monthly": 81700.0, "salary_divisor": 26.0, "divisor_basis": "profile", "deduction_base": "fixed_gross", "per_day_rate": 3142.3077, "lop_days": 0.0, "absent_days": 0, "half_days": 0, "unpaid_leave_days": 0, "paid_leave_days": 0, "pending_days": 0, "overtime_rate": 300.0, "overtime_multiplier": 1.5, "negative_net": false, "policy": {"week_off_days": [6], "full_day_min_hours": 6.0, "half_day_min_hours": 4.0, "overtime_threshold_minutes": 30, "early_checkout_threshold_minutes": 0, "missing_checkout_policy": "assume_required", "working_days_basis": "profile", "deduction_base": "fixed_gross", "deduct_absent_days": true, "half_day_deduction_factor": 0.5, "overtime_multiplier": 1.5, "pf_rate_percent": 12.0, "pf_wage_basis": "basic", "pf_wage_ceiling": 15000.0, "esi_rate_percent": 0.75, "esi_wage_basis": "gross", "esi_gross_ceiling": 21000.0, "rounding": "nearest_rupee"}}	PAID	2026-10-25 13:09:50.877848+05:30	2026-10-25 13:10:50.934088+05:30
9	2	5	26	26	0	0	0	4	211.58	7.92	26	0	0	42000.00	16800.00	12000.00	0.00	3206.00	74006.00	1800.00	0.00	200.00	0.00	0.00	2000.00	0.00	72006.00	{"fixed_monthly": 70800.0, "salary_divisor": 26.0, "divisor_basis": "profile", "deduction_base": "fixed_gross", "per_day_rate": 2723.0769, "lop_days": 0.0, "absent_days": 0, "half_days": 0, "unpaid_leave_days": 0, "paid_leave_days": 0, "pending_days": 0, "overtime_rate": 270.0, "overtime_multiplier": 1.5, "negative_net": false, "policy": {"week_off_days": [6], "full_day_min_hours": 6.0, "half_day_min_hours": 4.0, "overtime_threshold_minutes": 30, "early_checkout_threshold_minutes": 0, "missing_checkout_policy": "assume_required", "working_days_basis": "profile", "deduction_base": "fixed_gross", "deduct_absent_days": true, "half_day_deduction_factor": 0.5, "overtime_multiplier": 1.5, "pf_rate_percent": 12.0, "pf_wage_basis": "basic", "pf_wage_ceiling": 15000.0, "esi_rate_percent": 0.75, "esi_wage_basis": "gross", "esi_gross_ceiling": 21000.0, "rounding": "nearest_rupee"}}	PAID	2026-10-25 13:09:50.877848+05:30	2026-10-25 13:10:50.934088+05:30
10	2	1	26	26	0	0	0	4	211.58	7.92	4	0	0	55000.00	22000.00	18000.00	0.00	4156.00	99156.00	1800.00	0.00	200.00	0.00	0.00	2000.00	0.00	97156.00	{"fixed_monthly": 95000.0, "salary_divisor": 26.0, "divisor_basis": "profile", "deduction_base": "fixed_gross", "per_day_rate": 3653.8462, "lop_days": 0.0, "absent_days": 0, "half_days": 0, "unpaid_leave_days": 0, "paid_leave_days": 0, "pending_days": 0, "overtime_rate": 350.0, "overtime_multiplier": 1.5, "negative_net": false, "policy": {"week_off_days": [6], "full_day_min_hours": 6.0, "half_day_min_hours": 4.0, "overtime_threshold_minutes": 30, "early_checkout_threshold_minutes": 0, "missing_checkout_policy": "assume_required", "working_days_basis": "profile", "deduction_base": "fixed_gross", "deduct_absent_days": true, "half_day_deduction_factor": 0.5, "overtime_multiplier": 1.5, "pf_rate_percent": 12.0, "pf_wage_basis": "basic", "pf_wage_ceiling": 15000.0, "esi_rate_percent": 0.75, "esi_wage_basis": "gross", "esi_gross_ceiling": 21000.0, "rounding": "nearest_rupee"}}	PAID	2026-10-25 13:09:50.877848+05:30	2026-10-25 13:10:50.934088+05:30
8	2	4	26	26	0	0	0	4	211.58	7.92	4	0	0	38000.00	15200.00	11500.00	0.00	2969.00	67669.00	1800.00	0.00	200.00	0.00	0.00	2000.00	0.00	65669.00	{"fixed_monthly": 64700.0, "salary_divisor": 26.0, "divisor_basis": "profile", "deduction_base": "fixed_gross", "per_day_rate": 2488.4615, "lop_days": 0.0, "absent_days": 0, "half_days": 0, "unpaid_leave_days": 0, "paid_leave_days": 0, "pending_days": 0, "overtime_rate": 250.0, "overtime_multiplier": 1.5, "negative_net": false, "policy": {"week_off_days": [6], "full_day_min_hours": 6.0, "half_day_min_hours": 4.0, "overtime_threshold_minutes": 30, "early_checkout_threshold_minutes": 0, "missing_checkout_policy": "assume_required", "working_days_basis": "profile", "deduction_base": "fixed_gross", "deduct_absent_days": true, "half_day_deduction_factor": 0.5, "overtime_multiplier": 1.5, "pf_rate_percent": 12.0, "pf_wage_basis": "basic", "pf_wage_ceiling": 15000.0, "esi_rate_percent": 0.75, "esi_wage_basis": "gross", "esi_gross_ceiling": 21000.0, "rounding": "nearest_rupee"}}	PAID	2026-10-25 13:09:50.877848+05:30	2026-10-25 13:10:50.934088+05:30
\.


--
-- Data for Name: salary_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.salary_profiles (id, employee_id, basic_salary, hra, transport_allowance, medical_allowance, special_allowance, other_allowance, overtime_rate, working_hours_per_day, working_days_per_month, pf_enabled, esi_enabled, professional_tax, other_fixed_deduction, effective_from, created_at, updated_at) FROM stdin;
1	1	55000.00	22000.00	3000.00	2500.00	10000.00	2500.00	350.00	8	26	t	f	200.00	0.00	2026-01-01	2026-10-25 13:02:26.302428+05:30	2026-10-25 13:02:26.302428+05:30
2	2	48000.00	19200.00	2500.00	2000.00	8000.00	2000.00	300.00	8	26	t	f	200.00	0.00	2026-01-01	2026-10-25 13:02:26.302428+05:30	2026-10-25 13:02:26.302428+05:30
3	3	45000.00	18000.00	2500.00	2000.00	7500.00	1500.00	280.00	8	26	t	f	200.00	0.00	2026-01-01	2026-10-25 13:02:26.302428+05:30	2026-10-25 13:02:26.302428+05:30
4	4	38000.00	15200.00	2000.00	2000.00	6000.00	1500.00	250.00	8	26	t	f	200.00	0.00	2026-01-01	2026-10-25 13:02:26.302428+05:30	2026-10-25 13:02:26.302428+05:30
5	5	42000.00	16800.00	2000.00	2000.00	6500.00	1500.00	270.00	8	26	t	f	200.00	0.00	2026-01-01	2026-10-25 13:02:26.302428+05:30	2026-10-25 13:02:26.302428+05:30
\.


--
-- Data for Name: work_shifts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.work_shifts (id, name, start_time, end_time, break_minutes, grace_minutes, required_hours, is_default, is_active) FROM stdin;
1	General Shift	09:00:00	18:00:00	60	15	8	t	t
2	Morning Shift	07:30:00	16:30:00	60	15	8	f	t
\.


--
-- Name: attendance_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.attendance_events_id_seq', 7, true);


--
-- Name: attendance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.attendance_id_seq', 224, true);


--
-- Name: employee_shifts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employee_shifts_id_seq', 5, true);


--
-- Name: employees_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employees_id_seq', 6, true);


--
-- Name: face_embeddings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.face_embeddings_id_seq', 15, true);


--
-- Name: holidays_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.holidays_id_seq', 6, true);


--
-- Name: leave_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.leave_requests_id_seq', 2, true);


--
-- Name: leave_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.leave_types_id_seq', 5, true);


--
-- Name: offices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.offices_id_seq', 2, true);


--
-- Name: payroll_adjustments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payroll_adjustments_id_seq', 1, true);


--
-- Name: payroll_audit_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payroll_audit_log_id_seq', 15, true);


--
-- Name: payroll_periods_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payroll_periods_id_seq', 2, true);


--
-- Name: payroll_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payroll_records_id_seq', 10, true);


--
-- Name: salary_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.salary_profiles_id_seq', 5, true);


--
-- Name: work_shifts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.work_shifts_id_seq', 2, true);


--
-- Name: app_settings app_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_settings
    ADD CONSTRAINT app_settings_pkey PRIMARY KEY (key);


--
-- Name: attendance_events attendance_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance_events
    ADD CONSTRAINT attendance_events_pkey PRIMARY KEY (id);


--
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (id);


--
-- Name: employee_shifts employee_shifts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_shifts
    ADD CONSTRAINT employee_shifts_pkey PRIMARY KEY (id);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: face_embeddings face_embeddings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.face_embeddings
    ADD CONSTRAINT face_embeddings_pkey PRIMARY KEY (id);


--
-- Name: holidays holidays_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.holidays
    ADD CONSTRAINT holidays_pkey PRIMARY KEY (id);


--
-- Name: leave_requests leave_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_pkey PRIMARY KEY (id);


--
-- Name: leave_types leave_types_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leave_types
    ADD CONSTRAINT leave_types_code_key UNIQUE (code);


--
-- Name: leave_types leave_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leave_types
    ADD CONSTRAINT leave_types_pkey PRIMARY KEY (id);


--
-- Name: offices offices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.offices
    ADD CONSTRAINT offices_pkey PRIMARY KEY (id);


--
-- Name: payroll_adjustments payroll_adjustments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll_adjustments
    ADD CONSTRAINT payroll_adjustments_pkey PRIMARY KEY (id);


--
-- Name: payroll_audit_log payroll_audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll_audit_log
    ADD CONSTRAINT payroll_audit_log_pkey PRIMARY KEY (id);


--
-- Name: payroll_periods payroll_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll_periods
    ADD CONSTRAINT payroll_periods_pkey PRIMARY KEY (id);


--
-- Name: payroll_records payroll_records_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll_records
    ADD CONSTRAINT payroll_records_pkey PRIMARY KEY (id);


--
-- Name: salary_profiles salary_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary_profiles
    ADD CONSTRAINT salary_profiles_pkey PRIMARY KEY (id);


--
-- Name: attendance uq_employee_day; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT uq_employee_day UNIQUE (employee_id, attendance_date);


--
-- Name: payroll_records uq_payroll_emp_period; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll_records
    ADD CONSTRAINT uq_payroll_emp_period UNIQUE (payroll_period_id, employee_id);


--
-- Name: payroll_periods uq_payroll_period; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll_periods
    ADD CONSTRAINT uq_payroll_period UNIQUE (period_year, period_month);


--
-- Name: salary_profiles uq_salary_emp_from; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary_profiles
    ADD CONSTRAINT uq_salary_emp_from UNIQUE (employee_id, effective_from);


--
-- Name: work_shifts work_shifts_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_shifts
    ADD CONSTRAINT work_shifts_name_key UNIQUE (name);


--
-- Name: work_shifts work_shifts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_shifts
    ADD CONSTRAINT work_shifts_pkey PRIMARY KEY (id);


--
-- Name: ix_attendance_attendance_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_attendance_attendance_date ON public.attendance USING btree (attendance_date);


--
-- Name: ix_attendance_employee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_attendance_employee_id ON public.attendance USING btree (employee_id);


--
-- Name: ix_attendance_events_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_attendance_events_created_at ON public.attendance_events USING btree (created_at);


--
-- Name: ix_attendance_events_employee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_attendance_events_employee_id ON public.attendance_events USING btree (employee_id);


--
-- Name: ix_attendance_events_event_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_attendance_events_event_type ON public.attendance_events USING btree (event_type);


--
-- Name: ix_employee_shifts_employee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_employee_shifts_employee_id ON public.employee_shifts USING btree (employee_id);


--
-- Name: ix_employees_employee_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_employees_employee_code ON public.employees USING btree (employee_code);


--
-- Name: ix_employees_office_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_employees_office_id ON public.employees USING btree (office_id);


--
-- Name: ix_face_embeddings_employee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_face_embeddings_employee_id ON public.face_embeddings USING btree (employee_id);


--
-- Name: ix_holidays_holiday_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_holidays_holiday_date ON public.holidays USING btree (holiday_date);


--
-- Name: ix_leave_requests_employee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_leave_requests_employee_id ON public.leave_requests USING btree (employee_id);


--
-- Name: ix_leave_requests_start_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_leave_requests_start_date ON public.leave_requests USING btree (start_date);


--
-- Name: ix_leave_requests_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_leave_requests_status ON public.leave_requests USING btree (status);


--
-- Name: ix_offices_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_offices_code ON public.offices USING btree (code);


--
-- Name: ix_payroll_adjustments_payroll_record_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_payroll_adjustments_payroll_record_id ON public.payroll_adjustments USING btree (payroll_record_id);


--
-- Name: ix_payroll_audit_log_payroll_period_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_payroll_audit_log_payroll_period_id ON public.payroll_audit_log USING btree (payroll_period_id);


--
-- Name: ix_payroll_periods_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_payroll_periods_status ON public.payroll_periods USING btree (status);


--
-- Name: ix_payroll_records_employee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_payroll_records_employee_id ON public.payroll_records USING btree (employee_id);


--
-- Name: ix_payroll_records_payroll_period_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_payroll_records_payroll_period_id ON public.payroll_records USING btree (payroll_period_id);


--
-- Name: ix_salary_profiles_employee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_salary_profiles_employee_id ON public.salary_profiles USING btree (employee_id);


--
-- Name: attendance attendance_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: attendance_events attendance_events_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance_events
    ADD CONSTRAINT attendance_events_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE SET NULL;


--
-- Name: attendance_events attendance_events_office_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance_events
    ADD CONSTRAINT attendance_events_office_id_fkey FOREIGN KEY (office_id) REFERENCES public.offices(id);


--
-- Name: attendance attendance_office_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_office_id_fkey FOREIGN KEY (office_id) REFERENCES public.offices(id);


--
-- Name: employee_shifts employee_shifts_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_shifts
    ADD CONSTRAINT employee_shifts_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: employee_shifts employee_shifts_shift_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_shifts
    ADD CONSTRAINT employee_shifts_shift_id_fkey FOREIGN KEY (shift_id) REFERENCES public.work_shifts(id);


--
-- Name: employees employees_office_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_office_id_fkey FOREIGN KEY (office_id) REFERENCES public.offices(id);


--
-- Name: face_embeddings face_embeddings_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.face_embeddings
    ADD CONSTRAINT face_embeddings_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: leave_requests leave_requests_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: leave_requests leave_requests_leave_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_leave_type_id_fkey FOREIGN KEY (leave_type_id) REFERENCES public.leave_types(id);


--
-- Name: payroll_adjustments payroll_adjustments_payroll_record_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll_adjustments
    ADD CONSTRAINT payroll_adjustments_payroll_record_id_fkey FOREIGN KEY (payroll_record_id) REFERENCES public.payroll_records(id) ON DELETE CASCADE;


--
-- Name: payroll_audit_log payroll_audit_log_payroll_period_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll_audit_log
    ADD CONSTRAINT payroll_audit_log_payroll_period_id_fkey FOREIGN KEY (payroll_period_id) REFERENCES public.payroll_periods(id) ON DELETE CASCADE;


--
-- Name: payroll_records payroll_records_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll_records
    ADD CONSTRAINT payroll_records_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- Name: payroll_records payroll_records_payroll_period_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll_records
    ADD CONSTRAINT payroll_records_payroll_period_id_fkey FOREIGN KEY (payroll_period_id) REFERENCES public.payroll_periods(id) ON DELETE CASCADE;


--
-- Name: salary_profiles salary_profiles_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary_profiles
    ADD CONSTRAINT salary_profiles_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict OKk29DKa0z8WtmULsU8qAsm4Yk5vMIYTkfmUCWZQgzusHX0hiSRLDfur2bOgE36

