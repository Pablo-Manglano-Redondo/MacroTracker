import React, { useState } from 'react';
import { z } from 'zod';
import { useAuth } from '../lib/auth-context';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Card, CardContent } from './ui/card';
import { toast } from '../lib/toast';
import { ShieldCheck, UserCheck, BarChart2 } from 'lucide-react';

export const AuthPanel: React.FC = () => {
  const { login, loginWithPassword } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loginMode, setLoginMode] = useState<'magic-link' | 'password'>('magic-link');
  const [loading, setLoading] = useState(false);
  const [magicLinkSent, setMagicLinkSent] = useState(false);
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setFieldErrors({});

    // Validate email
    const emailResult = z.string().email().safeParse(email.trim());
    if (!emailResult.success) {
      setFieldErrors({ email: 'Please enter a valid email address.' });
      return;
    }
    const cleanEmail = emailResult.data;

    // Validate password if in password mode
    if (loginMode === 'password') {
      if (!password) {
        setFieldErrors({ password: 'Password is required.' });
        return;
      }
      if (password.length < 8) {
        setFieldErrors({ password: 'Password must be at least 8 characters.' });
        return;
      }
    }

    setLoading(true);

    if (loginMode === 'magic-link') {
      const { error } = await login(cleanEmail);
      if (error) {
        toast.error(error.message);
        setLoading(false);
      } else {
        setMagicLinkSent(true);
        setLoading(false);
      }
    } else {
      const { error } = await loginWithPassword(cleanEmail, password);
      if (error) {
        toast.error(error.message);
      }
      setLoading(false);
    }
  };

  return (
    <div className="grid grid-cols-1 md:grid-cols-12 gap-6 bg-card border rounded-lg p-6 shadow-sm">
      {/* Col 1: Marketing / Info */}
      <div className="md:col-span-5 flex flex-col justify-between space-y-6">
        <div>
          <p className="text-xs font-bold tracking-wider text-primary uppercase mb-2">Secure access</p>
          <h3 className="text-2xl font-bold tracking-tight mb-3">Sign in to your professional portal</h3>
          <p className="text-sm text-muted-foreground leading-relaxed">
            Access your practice workspace. Choose magic-link for frictionless sign-in or use your credentials.
          </p>
        </div>

        <div className="flex flex-col gap-3">
          <div className="flex items-center gap-2 text-sm font-semibold text-foreground/80">
            <ShieldCheck className="w-5 h-5 text-primary" />
            <span>Supabase RLS Enforced</span>
          </div>
          <div className="flex items-center gap-2 text-sm font-semibold text-foreground/80">
            <UserCheck className="w-5 h-5 text-primary" />
            <span>Client Consent Required</span>
          </div>
          <div className="flex items-center gap-2 text-sm font-semibold text-foreground/80">
            <BarChart2 className="w-5 h-5 text-primary" />
            <span>Aggregate Snapshots Only</span>
          </div>
        </div>
      </div>

      {/* Col 2: Step previews */}
      <div className="md:col-span-3 flex flex-col gap-3 justify-center">
        {[
          { index: '01', title: 'Activate Pro', desc: 'Stripe updates billing status server-side.' },
          { index: '02', title: 'Invite client', desc: 'Mobile app previews consent before connection.' },
          { index: '03', title: 'Publish plan', desc: 'Clients see targets while sharing aggregate progress.' }
        ].map((step, idx) => (
          <div key={idx} className="flex gap-4 items-start p-4 bg-muted/30 border rounded-lg">
            <span className="w-8 h-8 shrink-0 flex items-center justify-center rounded-full bg-accent text-accent-foreground text-xs font-black">
              {step.index}
            </span>
            <div>
              <h4 className="text-sm font-bold text-foreground">{step.title}</h4>
              <p className="text-xs text-muted-foreground mt-0.5 leading-tight">{step.desc}</p>
            </div>
          </div>
        ))}
      </div>

      {/* Col 3: Authentication Form */}
      <div className="md:col-span-4 flex flex-col justify-center">
        <Card className="border shadow-none">
          <CardContent className="p-6">
            {/* Login Mode Switcher Tabs */}
            <div className="flex bg-muted/40 p-1 rounded-lg border mb-4">
              <button
                type="button"
                disabled={loading}
                onClick={() => { setLoginMode('magic-link'); setFieldErrors({}); setMagicLinkSent(false); }}
                className={`flex-1 text-center text-xs font-bold py-1.5 rounded-md transition-all ${
                  loginMode === 'magic-link'
                    ? 'bg-primary text-primary-foreground shadow-sm'
                    : 'text-muted-foreground hover:text-foreground disabled:opacity-50'
                }`}
              >
                Magic Link
              </button>
              <button
                type="button"
                disabled={loading}
                onClick={() => { setLoginMode('password'); setFieldErrors({}); }}
                className={`flex-1 text-center text-xs font-bold py-1.5 rounded-md transition-all ${
                  loginMode === 'password'
                    ? 'bg-primary text-primary-foreground shadow-sm'
                    : 'text-muted-foreground hover:text-foreground disabled:opacity-50'
                }`}
              >
                Password
              </button>
            </div>

            {magicLinkSent ? (
              <div className="text-center py-4 space-y-3">
                <span className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-accent text-primary mb-2">
                  ✓
                </span>
                <h4 className="text-base font-bold">Magic link sent!</h4>
                <p className="text-xs text-muted-foreground leading-relaxed">
                  Check your email inbox at <strong>{email}</strong> for the secure sign-in link.
                </p>
                <Button variant="outline" size="sm" onClick={() => { setMagicLinkSent(false); setFieldErrors({}); }} className="w-full mt-4">
                  Back
                </Button>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="space-y-1.5">
                  <label className="text-xs font-extrabold text-foreground uppercase tracking-wider">
                    Professional Email
                  </label>
                  <Input
                    type="email"
                    placeholder="nutritionist@example.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    disabled={loading}
                  />
                  {fieldErrors.email && (
                    <p className="text-xs font-medium text-destructive">{fieldErrors.email}</p>
                  )}
                </div>

                {loginMode === 'password' && (
                  <div className="space-y-1.5 animate-in fade-in duration-200">
                    <label className="text-xs font-extrabold text-foreground uppercase tracking-wider">
                      Password
                    </label>
                    <Input
                      type="password"
                      placeholder="••••••••"
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      disabled={loading}
                    />
                    {fieldErrors.password && (
                      <p className="text-xs font-medium text-destructive">{fieldErrors.password}</p>
                    )}
                  </div>
                )}

                <Button type="submit" className="w-full h-10 font-bold" disabled={loading}>
                  {loading
                    ? 'Signing in...'
                    : loginMode === 'magic-link'
                      ? 'Send magic link'
                      : 'Sign in'}
                </Button>
              </form>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
};
