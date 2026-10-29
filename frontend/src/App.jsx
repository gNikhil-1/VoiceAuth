import { useState } from 'react';
import './App.css';

export default function App() {
  const [mode, setMode] = useState('login');
  const [showPassword, setShowPassword] = useState(false);
  const [form, setForm] = useState({ name: '', email: '', password: '' });
  const [message, setMessage] = useState('');

  const isRegister = mode === 'register';

  function updateField(event) {
    setForm({ ...form, [event.target.name]: event.target.value });
    setMessage('');
  }

  function handleSubmit(event) {
  event.preventDefault();

  if (isRegister) {
    setMessage(`Registration button clicked for ${form.email}!`);
  } else {
    setMessage(`Login button clicked for ${form.email}!`);
  }
}

  function switchMode(nextMode) {
    setMode(nextMode);
    setMessage('');
    setShowPassword(false);
  }

  return (
    <main className="page-shell">
      <section className="auth-card" aria-label="VoiceAuth student account">
        <div className="brand-row">
          <div className="brand-mark" aria-hidden="true">
            <svg viewBox="0 0 32 32" role="img">
              <path d="M16 3.5 26 7v7.3c0 6.1-4.1 11.4-10 14.2C10.1 25.7 6 20.4 6 14.3V7l10-3.5Z" />
              <path d="M12.2 15.8v-2.2m3.8 5.2V10m3.8 5.8v-2.2" />
            </svg>
          </div>
          <span className="brand-name">Voice<span>Auth</span></span>
        </div>

        <div className="intro">
          <p className="eyebrow">STUDENT PORTAL</p>
          <h1>{isRegister ? 'Create your account' : 'Welcome back'}</h1>
          <p className="subtitle">
            {isRegister
              ? 'Register to make your campus deliveries easier to verify.'
              : 'Sign in to manage and verify your campus deliveries.'}
          </p>
        </div>

        <div className="mode-switch" role="tablist" aria-label="Choose login or registration">
          <button
            type="button"
            role="tab"
            aria-selected={!isRegister}
            className={!isRegister ? 'active' : ''}
            onClick={() => switchMode('login')}
          >
            Log in
          </button>
          <button
            type="button"
            role="tab"
            aria-selected={isRegister}
            className={isRegister ? 'active' : ''}
            onClick={() => switchMode('register')}
          >
            Register
          </button>
        </div>

        <form className="auth-form" onSubmit={handleSubmit}>
          {isRegister && (
            <label className="field-label">
              Full name
              <input
                type="text"
                name="name"
                value={form.name}
                onChange={updateField}
                placeholder="Enter your full name"
                autoComplete="name"
                required
              />
            </label>
          )}

          <label className="field-label">
            Student email
            <input
              type="email"
              name="email"
              value={form.email}
              onChange={updateField}
              placeholder="you@iitb.ac.in"
              autoComplete="email"
              required
            />
          </label>

          <label className="field-label">
            Password
            <div className="password-wrap">
              <input
                type={showPassword ? 'text' : 'password'}
                name="password"
                value={form.password}
                onChange={updateField}
                placeholder={isRegister ? 'Create a password' : 'Enter your password'}
                autoComplete={isRegister ? 'new-password' : 'current-password'}
                minLength={6}
                required
              />
              <button
                className="show-password"
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                aria-label={showPassword ? 'Hide password' : 'Show password'}
              >
                {showPassword ? 'Hide' : 'Show'}
              </button>
            </div>
            {isRegister && <span className="field-hint">Use at least 6 characters.</span>}
          </label>

          {!isRegister && (
            <div className="form-options">
              <label className="remember-option">
                <input type="checkbox" />
                <span>Remember me</span>
              </label>
              <span className="forgot-note">Forgot password?</span>
            </div>
          )}

          <button className="submit-button" type="submit">
            {isRegister ? 'Create account' : 'Log in'}
            <span aria-hidden="true">→</span>
          </button>

          {message && <p className="form-message" role="status">{message}</p>}
        </form>

        <p className="switch-prompt">
          {isRegister ? 'Already have an account?' : 'New to VoiceAuth?'}{' '}
          <button type="button" onClick={() => switchMode(isRegister ? 'login' : 'register')}>
            {isRegister ? 'Log in' : 'Create an account'}
          </button>
        </p>

        <div className="security-note">
          <span className="lock-icon" aria-hidden="true">♧</span>
          <span>Built for simpler, safer campus deliveries</span>
        </div>
      </section>
      <footer className="page-footer">VoiceAuth · Student delivery verification</footer>
    </main>
  );
}
