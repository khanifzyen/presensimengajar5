import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';

// Types
export interface User {
    id: string;
    email: string;
    name: string;
    role: 'admin' | 'teacher';
    nip?: string;
    subject?: string;
    avatar?: string;
}

export interface AuthContextType {
    user: User | null;
    login: (email: string, password: string) => Promise<boolean>;
    logout: () => Promise<void>;
    isLoading: boolean;
}

// Create context
const AuthContext = createContext<AuthContextType | undefined>(undefined);

// Mock user data for development
const mockUser: User = {
    id: '1',
    email: 'budi.santoso@smpn1.sch.id',
    name: 'Budi Santoso, S.Pd',
    role: 'teacher',
    nip: '198506152008011001',
    subject: 'Matematika',
    avatar: 'https://placehold.co/50x50/white/1e3a8a?text=BS'
};

// Auth Provider Component
export function AuthProvider({ children }: { children: ReactNode }) {
    const [user, setUser] = useState<User | null>(null);
    const [isLoading, setIsLoading] = useState(false);

    // Mock login function
    const login = async (email: string, password: string): Promise<boolean> => {
        setIsLoading(true);

        try {
            // Simulate API call
            await new Promise(resolve => setTimeout(resolve, 1000));

            // Mock successful login
            if (email === 'budi.santoso@smpn1.sch.id' && password === 'password123') {
                setUser(mockUser);
                return true;
            } else {
                return false;
            }
        } catch (error) {
            console.error('Login error:', error);
            return false;
        } finally {
            setIsLoading(false);
        }
    };

    const logout = async (): Promise<void> => {
        setIsLoading(true);

        try {
            // Simulate API call
            await new Promise(resolve => setTimeout(resolve, 500));
            setUser(null);
        } catch (error) {
            console.error('Logout error:', error);
        } finally {
            setIsLoading(false);
        }
    };

    // Check if user is logged in on mount
    useEffect(() => {
        // For now, auto-login with mock user for development
        setUser(mockUser);
    }, []);

    const value: AuthContextType = {
        user,
        login,
        logout,
        isLoading
    };

    return (
        <AuthContext.Provider value={value}>
            {children}
        </AuthContext.Provider>
    );
}

// Custom hook to use auth context
export function useAuth() {
    const context = useContext(AuthContext);

    if (context === undefined) {
        throw new Error('useAuth must be used within an AuthProvider');
    }

    return context;
}