// TypeScript Microfrontend with Strong Typing

interface User {
  id: number;
  name: string;
  email: string;
  role: 'admin' | 'user' | 'guest';
  createdAt: Date;
}

interface ApiResponse<T> {
  data: T;
  status: 'success' | 'error';
  message: string;
  timestamp: string;
}

interface AppState {
  users: User[];
  selectedUser: User | null;
  loading: boolean;
  error: string | null;
}

class TypeScriptApp {
  private container: HTMLElement | null = null;
  private state: AppState = {
    users: [],
    selectedUser: null,
    loading: false,
    error: null
  };

  public mount(props?: any): Promise<void> {
    return new Promise((resolve) => {
      this.container = document.getElementById('typescript-app');
      if (!this.container) {
        console.error('Mount point #typescript-app not found');
        return resolve();
      }

      this.render();
      this.attachEventListeners();
      console.log('📘 TypeScript App mounted');
      resolve();
    });
  }

  public unmount(): Promise<void> {
    return new Promise((resolve) => {
      if (this.container) {
        this.container.innerHTML = '';
      }
      console.log('📘 TypeScript App unmounted');
      resolve();
    });
  }

  private render(): void {
    if (!this.container) return;

    const now = new Date().toLocaleString();
    
    this.container.innerHTML = `
      <div style="padding: 20px; border: 2px solid #007bff; border-radius: 8px; margin: 10px 0; background: #f8f9fa;">
        <h2 style="color: #007bff; margin: 0 0 15px 0;">
          <img src="https://upload.wikimedia.org/wikipedia/commons/4/4c/Typescript_logo_2020.svg" width="40" height="40" style="vertical-align: middle; margin-right: 10px;">
          TypeScript Microfrontend
        </h2>
        <p><strong>Language:</strong> TypeScript with strict type checking</p>
        <p><strong>Features:</strong> Interfaces, Generics, Type Safety, IntelliSense</p>
        <p><strong>Mounted at:</strong> ${now}</p>
        
        <div style="margin: 15px 0;">
          <button id="ts-load-users" style="
            background: #007bff; 
            color: white; 
            border: none; 
            padding: 8px 16px; 
            border-radius: 4px; 
            cursor: pointer;
            margin-right: 10px;
          ">
            Load Users
          </button>
          
          <button id="ts-add-user" style="
            background: #28a745; 
            color: white; 
            border: none; 
            padding: 8px 16px; 
            border-radius: 4px; 
            cursor: pointer;
          ">
            Add Random User
          </button>
        </div>
        
        <div id="ts-users-list" style="
          margin-top: 15px; 
          padding: 10px; 
          background: #e9ecef; 
          border-radius: 4px;
          min-height: 100px;
        ">
          <em>Click "Load Users" to fetch typed data...</em>
        </div>
        
        <div style="margin-top: 15px; font-size: 0.9em; color: #6c757d;">
          <strong>TypeScript Features:</strong>
          <ul style="margin: 5px 0; padding-left: 20px;">
            <li>Strong Type Checking</li>
            <li>Interface Definitions</li>
            <li>Generic Types</li>
            <li>Compile-time Error Detection</li>
            <li>Enhanced IDE Support</li>
          </ul>
        </div>
      </div>
    `;
  }

  private attachEventListeners(): void {
    const loadUsersBtn = this.container?.querySelector('#ts-load-users') as HTMLButtonElement;
    const addUserBtn = this.container?.querySelector('#ts-add-user') as HTMLButtonElement;

    loadUsersBtn?.addEventListener('click', () => this.loadUsers());
    addUserBtn?.addEventListener('click', () => this.addRandomUser());
  }

  private async loadUsers(): Promise<void> {
    this.setState({ loading: true, error: null });
    this.updateUsersDisplay();

    try {
      // Simulate API call with typed response
      const response: ApiResponse<User[]> = await this.fetchUsersFromAPI();
      
      if (response.status === 'success') {
        this.setState({ 
          users: response.data, 
          loading: false 
        });
      } else {
        throw new Error(response.message);
      }
    } catch (error) {
      this.setState({ 
        loading: false, 
        error: error instanceof Error ? error.message : 'Unknown error' 
      });
    }

    this.updateUsersDisplay();
  }

  private async fetchUsersFromAPI(): Promise<ApiResponse<User[]>> {
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 1000));

    const mockUsers: User[] = [
      {
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        role: 'admin',
        createdAt: new Date('2023-01-15')
      },
      {
        id: 2,
        name: 'Jane Smith',
        email: 'jane@example.com',
        role: 'user',
        createdAt: new Date('2023-02-20')
      },
      {
        id: 3,
        name: 'Bob Johnson',
        email: 'bob@example.com',
        role: 'guest',
        createdAt: new Date('2023-03-10')
      }
    ];

    return {
      data: mockUsers,
      status: 'success',
      message: 'Users loaded successfully',
      timestamp: new Date().toISOString()
    };
  }

  private addRandomUser(): void {
    const names = ['Alice Cooper', 'Charlie Brown', 'Diana Prince', 'Edward Norton'];
    const roles: User['role'][] = ['admin', 'user', 'guest'];
    
    const randomName = names[Math.floor(Math.random() * names.length)];
    const randomRole = roles[Math.floor(Math.random() * roles.length)];
    
    const newUser: User = {
      id: this.state.users.length + 1,
      name: randomName,
      email: `${randomName.toLowerCase().replace(' ', '.')}@example.com`,
      role: randomRole,
      createdAt: new Date()
    };

    this.setState({
      users: [...this.state.users, newUser]
    });

    this.updateUsersDisplay();
  }

  private setState(newState: Partial<AppState>): void {
    this.state = { ...this.state, ...newState };
  }

  private updateUsersDisplay(): void {
    const usersListDiv = this.container?.querySelector('#ts-users-list') as HTMLDivElement;
    if (!usersListDiv) return;

    if (this.state.loading) {
      usersListDiv.innerHTML = '<em>Loading users...</em>';
      return;
    }

    if (this.state.error) {
      usersListDiv.innerHTML = `<span style="color: #dc3545;">Error: ${this.state.error}</span>`;
      return;
    }

    if (this.state.users.length === 0) {
      usersListDiv.innerHTML = '<em>No users loaded. Click "Load Users" to fetch data.</em>';
      return;
    }

    const usersHtml = this.state.users.map(user => `
      <div style="
        background: white; 
        padding: 10px; 
        margin: 5px 0; 
        border-radius: 4px; 
        border-left: 4px solid ${this.getRoleColor(user.role)};
      ">
        <strong>${user.name}</strong> (${user.role})
        <br>
        <small>${user.email} • Created: ${user.createdAt.toLocaleDateString()}</small>
      </div>
    `).join('');

    usersListDiv.innerHTML = `
      <strong>Users (${this.state.users.length}):</strong>
      ${usersHtml}
    `;
  }

  private getRoleColor(role: User['role']): string {
    const colors: Record<User['role'], string> = {
      admin: '#dc3545',
      user: '#007bff',
      guest: '#6c757d'
    };
    return colors[role];
  }
}

// Single-SPA Lifecycle Functions
const typeScriptApp = new TypeScriptApp();

export const bootstrap = (): Promise<void> => Promise.resolve();
export const mount = (props?: any): Promise<void> => typeScriptApp.mount(props);
export const unmount = (): Promise<void> => typeScriptApp.unmount();

export default {
  bootstrap,
  mount,
  unmount
};