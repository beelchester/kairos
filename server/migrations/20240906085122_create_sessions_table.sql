CREATE TABLE sessions (
    session_id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    started_at TIMESTAMP WITH TIME ZONE NOT NULL,
    ended_at TIMESTAMP WITH TIME ZONE,
    duration INTEGER NOT NULL
);

CREATE INDEX idx_sessions_started_at ON sessions (started_at);
CREATE INDEX idx_sessions_id ON sessions (session_id);
CREATE INDEX idx_sessions_user_id ON sessions (user_id);

