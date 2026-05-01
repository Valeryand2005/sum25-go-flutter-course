package database

import (
	"database/sql"
	"errors"
	"fmt"
	"os"
	"path/filepath"

	"github.com/pressly/goose/v3"
)

// migrationsDir resolves the goose migrations folder for both:
//   - go run .  (cwd backend/)  → ./migrations
//   - go test ./database (cwd backend/database/) → ../migrations
func migrationsDir() (string, error) {
	candidates := []string{"migrations", filepath.Join("..", "migrations")}
	for _, d := range candidates {
		if fi, err := os.Stat(d); err == nil && fi.IsDir() {
			return d, nil
		}
	}
	return "", fmt.Errorf("migrations directory not found (tried: %v)", candidates)
}

// RunMigrations runs database migrations using goose
func RunMigrations(db *sql.DB) error {
	if db == nil {
		return fmt.Errorf("database connection cannot be nil")
	}

	// Set goose dialect for SQLite
	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	dir, err := migrationsDir()
	if err != nil {
		return err
	}
	if err := goose.Up(db, dir); err != nil {
		return fmt.Errorf("failed to run migrations: %v", err)
	}

	return nil
}

// TODO: Implement this function
// RollbackMigration rolls back the last migration using goose
func RollbackMigration(db *sql.DB) error {
	if db == nil {
		return errors.New("database connection is nil")
	}
	err := goose.SetDialect("sqlite3")
	if err != nil {
		return errors.New("failed to set goose dialect")
	}

	dir, derr := migrationsDir()
	if derr != nil {
		return derr
	}
	err = goose.Down(db, dir)
	if err != nil {
		return errors.New("failed to rollback migration")
	}
	return nil
}

// TODO: Implement this function
// GetMigrationStatus checks migration status using goose
func GetMigrationStatus(db *sql.DB) error {
	if db == nil {
		return errors.New("database connection is nil")
	}
	err := goose.SetDialect("sqlite3")
	if err != nil {
		return errors.New("failed to set goose dialect")
	}

	dir, derr := migrationsDir()
	if derr != nil {
		return derr
	}
	err = goose.Status(db, dir)
	if err != nil {
		return errors.New("failed to get migration status")
	}
	return nil
}

// TODO: Implement this function
// CreateMigration creates a new migration file
func CreateMigration(name string) error {
	if name == "" {
		return fmt.Errorf("migration name cannot be empty")
	}

	dir, err := migrationsDir()
	if err != nil {
		dir = "migrations"
		if err := os.MkdirAll(dir, 0755); err != nil {
			return fmt.Errorf("failed to create migrations directory: %v", err)
		}
	}

	if err := goose.SetDialect("sqlite3"); err != nil {
		return fmt.Errorf("failed to set goose dialect: %v", err)
	}

	if err := goose.Create(nil, dir, name, "sql"); err != nil {
		return fmt.Errorf("failed to create migration: %v", err)
	}

	return nil
}