-- +goose Up
-- +goose StatementBegin

-- Create a new table with the desired schema
CREATE TABLE films_new (
    -- Existing columns
    title TEXT,
    director TEXT,
    
    -- New columns with default values
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Copy data from the old table to the new table
INSERT INTO films_new (title, director, createdAt, updatedAt)
SELECT title, director, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM films;

-- Delete the old table
DROP TABLE films;

-- Rename the new table to the original table's name
ALTER TABLE films_new RENAME TO films;

-- Create a trigger to update the updatedAt column
CREATE TRIGGER update_films_timestamp
AFTER UPDATE ON films
BEGIN
    UPDATE films SET updatedAt = CURRENT_TIMESTAMP WHERE rowid = NEW.rowid;
END;

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

-- Reverse the migration by deleting the new table and trigger
DROP TABLE films;
DROP TRIGGER update_films_timestamp;

-- +goose StatementEnd
