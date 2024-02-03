-- +goose Up
-- +goose StatementBegin

-- Check if the 'films_new' table exists
CREATE TABLE IF NOT EXISTS films_new (
    -- Existing columns
    title TEXT,
    director TEXT,
    
    -- New columns with default values
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Check if the 'films' table exists
CREATE TABLE IF NOT EXISTS films (
    -- Existing columns
    title TEXT,
    director TEXT,
    
    -- New columns with default values
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Copy data from the old 'films' table to the new 'films_new' table if the 'films' table exists
INSERT INTO films_new (title, director, createdAt, updatedAt)
SELECT title, director, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM films;

-- Drop the old 'films' table if it exists
DROP TABLE IF EXISTS films;

-- Rename the new 'films_new' table to the original 'films' table's name
ALTER TABLE films_new RENAME TO films;

-- Create a trigger to update the updatedAt column
CREATE TRIGGER IF NOT EXISTS update_films_timestamp
AFTER UPDATE ON films
BEGIN
    UPDATE films SET updatedAt = CURRENT_TIMESTAMP WHERE rowid = NEW.rowid;
END;

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

-- Reverse the migration by deleting the new 'films' table and trigger
DROP TABLE IF EXISTS films;
DROP TRIGGER IF EXISTS update_films_timestamp;

-- +goose StatementEnd
