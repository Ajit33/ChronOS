CREATE TYPE job_status AS ENUM ('active', 'paused', 'completed', 'failed')
CREATE TYPE job_execution_status AS ENUM ('success', 'failure', 'retrying', 'pending');
CREATE TABLE IF NOT EXISTS clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS jobs(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL,
    url VARCHAR(255) NOT NULL,
    cron_expression VARCHAR(255) NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    max_retries INTEGER DEFAULT 3,
    status job_status DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255) NOT NULL,
    next_run_at TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS job_executions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id UUID NOT NULL,
    started_at TIMESTAMP NOT NULL,
    finished_at TIMESTAMP,
    duration INTERVAL,
    status job_execution_status DEFAULT 'pending',
    current_retry INTEGER DEFAULT 0,
    result TEXT,
    error_message TEXT,
    response_code INTEGER,
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE
);

CREATE INDEX idx_jobs_next_run_at ON jobs(next_run_at);
CREATE INDEX idx_jobs_status ON jobs(status);
CREATE INDEX idx_job_executions_job_id ON job_executions(job_id);