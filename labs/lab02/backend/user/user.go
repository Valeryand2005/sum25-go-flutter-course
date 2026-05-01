package user

import (
	"context"
	"errors"
	"strings"
	"sync"
)

// User represents a chat user

type User struct {
	Name  string
	Email string
	ID    string
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	// TODO: Validate name, email, id
	if u.Name == "" {
		return errors.New("name is required")
	}
	if u.Email == "" {
		return errors.New("email is required")
	}
	if !strings.Contains(u.Email, "@") {
		return errors.New("email is invalid")
	}
	if u.ID == "" {
		return errors.New("id is required")
	}
	if len(u.Name) > 30 {
		return errors.New("name is too long")
	}
	if len(u.Email) > 255 {
		return errors.New("email is too long")
	}
	if len(u.ID) > 36 {
		return errors.New("id is too long")
	}
	return nil
}

// UserManager manages users
// Contains a map of users, a mutex, and a context

type UserManager struct {
	ctx   context.Context
	users map[string]User // userID -> User
	mutex sync.RWMutex    // Protects users map
	// TODO: Add more fields if needed
	done     chan struct{}
	doneMutex sync.RWMutex
	doneChan  chan struct{}
	doneChanMutex sync.RWMutex
	doneChanCond  sync.Cond
	doneChanCondMutex sync.RWMutex
	doneChanCondCond  sync.Cond
	doneChanCondCondMutex sync.RWMutex
	doneChanCondCondCond  sync.Cond
}

// NewUserManager creates a new UserManager
func NewUserManager() *UserManager {
	// TODO: Initialize UserManager fields
	return &UserManager{
		ctx: context.Background(),
		users: make(map[string]User),
		done: make(chan struct{}),
		doneMutex: sync.RWMutex{},
		doneChan: make(chan struct{}),
		doneChanMutex: sync.RWMutex{},
		doneChanCond: sync.Cond{},
		doneChanCondMutex: sync.RWMutex{},
		doneChanCondCond: sync.Cond{},
		doneChanCondCondMutex: sync.RWMutex{},
		doneChanCondCondCond: sync.Cond{},
	}
}

// NewUserManagerWithContext creates a new UserManager with context
func NewUserManagerWithContext(ctx context.Context) *UserManager {
	// TODO: Initialize UserManager with context
	if ctx == nil {
		ctx = context.Background()
	}
	return &UserManager{
		ctx:   ctx,
		users: make(map[string]User),
		done: make(chan struct{}),
		doneMutex: sync.RWMutex{},
		doneChan: make(chan struct{}),
		doneChanMutex: sync.RWMutex{},
		doneChanCond: sync.Cond{},
		doneChanCondMutex: sync.RWMutex{},
		doneChanCondCond: sync.Cond{},
		doneChanCondCondMutex: sync.RWMutex{},
		doneChanCondCondCond: sync.Cond{},
	}
}

// AddUser adds a user
func (m *UserManager) AddUser(u User) error {
	// TODO: Add user to map, check context
	if m.ctx.Err() != nil {
		return errors.New("context is done")
	}
	m.mutex.Lock()
	defer m.mutex.Unlock()
	m.users[u.ID] = u
	return nil
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	// TODO: Remove user from map
	if m.ctx.Err() != nil {
		return errors.New("context is done")
	}
	m.mutex.Lock()
	defer m.mutex.Unlock()
	delete(m.users, id)
	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	// TODO: Get user from map
	if m.ctx.Err() != nil {
		return User{}, errors.New("context is done")
	}
	m.mutex.RLock()
	defer m.mutex.RUnlock()
	user, ok := m.users[id]
	if !ok {
		return User{}, errors.New("user not found")
	}
	return user, nil
}
