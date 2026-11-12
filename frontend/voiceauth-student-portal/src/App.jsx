import { useMemo, useState } from 'react';
import {
  Activity, Bell, Box, Check, ChevronDown, ChevronRight, CircleHelp,
  Clock3, FileText, LayoutDashboard, LogOut, Package, PackagePlus,
  Search, Settings, ShieldCheck, UserRound, X
} from 'lucide-react';

const initialDeliveries = [
  { id: 'VA-24081', order: 'AMZ-4829137', platform: 'Amazon', item: 'Electronics accessory', date: '2026-11-12', status: 'Expected', note: 'USB-C hub', gate: 'Main Gate' },
  { id: 'VA-24080', order: 'FK-7291042', platform: 'Flipkart', item: 'Books', date: '2026-11-11', status: 'Received', note: 'Course material', gate: 'Main Gate' },
  { id: 'VA-24079', order: 'SW-1830271', platform: 'Swiggy', item: 'Food order', date: '2026-11-11', status: 'Received', note: '', gate: 'North Gate' },
  { id: 'VA-24078', order: 'AMZ-3928104', platform: 'Amazon', item: 'Personal items', date: '2026-11-13', status: 'Expected', note: '', gate: 'Main Gate' },
  { id: 'VA-24077', order: 'MY-8391023', platform: 'Myntra', item: 'Clothing', date: '2026-11-10', status: 'Expired', note: '', gate: 'Main Gate' },
];

const initialNotifications = [
  { id: 1, title: 'Delivery received', body: 'Your Flipkart order FK-7291042 was marked as received at the Main Gate.', time: 'Today, 10:42 AM', unread: true },
  { id: 2, title: 'Delivery received', body: 'Your Swiggy order SW-1830271 was marked as received at the North Gate.', time: 'Today, 9:18 AM', unread: true },
  { id: 3, title: 'Delivery registered', body: 'Your Amazon order AMZ-4829137 has been added to expected deliveries.', time: 'Yesterday, 6:30 PM', unread: false },
];

const navItems = [
  { id: 'overview', label: 'Overview', icon: LayoutDashboard },
  { id: 'register', label: 'Register delivery', icon: PackagePlus },
  { id: 'deliveries', label: 'My deliveries', icon: Package },
  { id: 'notifications', label: 'Notifications', icon: Bell },
];

function Brand() {
  return <div className="brand"><div className="brand-symbol"><ShieldCheck size={19} strokeWidth={1.8} /></div><span>Voice<span className="brand-accent">Auth</span></span></div>;
}

function Status({ value }) {
  const cls = value.toLowerCase().replaceAll(' ', '-');
  return <span className={`status status-${cls}`}><span className="status-dot" />{value}</span>;
}

function App() {
  const [page, setPage] = useState('overview');
  const [deliveries, setDeliveries] = useState(initialDeliveries);
  const [notifications, setNotifications] = useState(initialNotifications);
  const [query, setQuery] = useState('');
  const [filter, setFilter] = useState('All');
  const [form, setForm] = useState({ platform: 'Amazon', order: '', date: '2026-11-12', item: '', note: '', gate: 'Main Gate' });
  const [toast, setToast] = useState('');
  const [profile, setProfile] = useState({
    name: 'Pratyush Gadge',
    roll: '24BXXXX',
    email: 'pratyush.gadge@iitb.ac.in',
    hostel: 'Hostel 12'
  });

  const unread = notifications.filter(n => n.unread).length;
  const expected = deliveries.filter(d => d.status === 'Expected').length;
  const received = deliveries.filter(d => d.status === 'Received').length;

  const filtered = useMemo(() => deliveries.filter(d => {
    const matchesQuery = [d.order, d.platform, d.item, d.id].join(' ').toLowerCase().includes(query.toLowerCase());
    return matchesQuery && (filter === 'All' || d.status === filter);
  }), [deliveries, query, filter]);

  function notify(message) {
    setToast(message);
    window.clearTimeout(window.__voiceAuthToast);
    window.__voiceAuthToast = window.setTimeout(() => setToast(''), 2800);
  }

  function registerDelivery(e) {
    e.preventDefault();
    const newDelivery = {
      id: `VA-${Math.floor(24082 + Math.random() * 900)}`,
      order: form.order.trim(),
      platform: form.platform,
      item: form.item.trim() || 'Not specified',
      date: form.date,
      status: 'Expected',
      note: form.note.trim(),
      gate: form.gate
    };
    setDeliveries(current => [newDelivery, ...current]);
    setNotifications(current => [{
      id: Date.now(), title: 'Delivery registered',
      body: `Your ${form.platform} order ${form.order.trim()} has been added to expected deliveries.`,
      time: 'Just now', unread: true
    }, ...current]);
    setForm({ platform: 'Amazon', order: '', date: '2026-11-12', item: '', note: '', gate: 'Main Gate' });
    setPage('deliveries');
    notify('Delivery registered successfully');
  }

  function markAllRead() {
    setNotifications(current => current.map(n => ({ ...n, unread: false })));
    notify('All notifications marked as read');
  }

  function renderOverview() {
    return <>
      <div className="page-heading">
        <div><p className="eyebrow">STUDENT PORTAL</p><h1>Good evening, Pratyush</h1><p className="muted">Here’s an overview of your campus deliveries.</p></div>
        <button className="button button-primary" onClick={() => setPage('register')}><PackagePlus size={16}/> Register delivery</button>
      </div>
      <section className="stats-grid">
        <div className="stat-card"><div className="stat-top"><span>Expected deliveries</span><span className="stat-icon"><Clock3 size={17}/></span></div><strong>{expected}</strong><small>Awaiting arrival</small></div>
        <div className="stat-card"><div className="stat-top"><span>Received</span><span className="stat-icon green"><Check size={17}/></span></div><strong>{received}</strong><small>Successfully verified</small></div>
        <div className="stat-card"><div className="stat-top"><span>Total registered</span><span className="stat-icon"><Box size={17}/></span></div><strong>{deliveries.length}</strong><small>All your deliveries</small></div>
      </section>
      <section className="content-card">
        <div className="section-heading"><div><h2>Recent deliveries</h2><p className="muted">A quick look at your latest registered orders.</p></div><button className="text-button" onClick={() => setPage('deliveries')}>View all <ChevronRight size={15}/></button></div>
        <DeliveryTable rows={deliveries.slice(0, 4)} />
      </section>
      <section className="content-card activity-card">
        <div className="section-heading"><div><h2>Recent activity</h2><p className="muted">Updates related to your deliveries.</p></div><button className="text-button" onClick={() => setPage('notifications')}>View notifications <ChevronRight size={15}/></button></div>
        {notifications.slice(0, 2).map(n => <div className="activity-row" key={n.id}><span className="activity-icon"><Bell size={16}/></span><div><strong>{n.title}</strong><p>{n.body}</p></div><time>{n.time}</time></div>)}
      </section>
    </>;
  }

  function renderRegister() {
    return <>
      <div className="page-heading"><div><p className="eyebrow">DELIVERIES</p><h1>Register a delivery</h1><p className="muted">Add an expected order so it can be verified when it reaches the gate.</p></div></div>
      <div className="form-layout">
        <form className="content-card delivery-form" onSubmit={registerDelivery}>
          <div className="form-section-title"><h2>Order information</h2><p className="muted">Fields marked with * are required.</p></div>
          <label>Delivery platform <span>*</span><select value={form.platform} onChange={e => setForm({...form, platform:e.target.value})}><option>Amazon</option><option>Flipkart</option><option>Swiggy</option><option>Zomato</option><option>Myntra</option><option>Other</option></select></label>
          <label>Order ID <span>*</span><input required value={form.order} onChange={e => setForm({...form, order:e.target.value})} placeholder="Enter the order or reference ID" /></label>
          <div className="form-two"><label>Expected delivery date <span>*</span><input required type="date" value={form.date} onChange={e => setForm({...form, date:e.target.value})} /></label><label>Entry gate<select value={form.gate} onChange={e => setForm({...form, gate:e.target.value})}><option>Main Gate</option><option>North Gate</option><option>Other</option></select></label></div>
          <label>Item description<input value={form.item} onChange={e => setForm({...form, item:e.target.value})} placeholder="e.g. Books, groceries, electronics" /></label>
          <label>Additional notes <small>(optional)</small><textarea rows="3" value={form.note} onChange={e => setForm({...form, note:e.target.value})} placeholder="Any information that may help identify your delivery" /></label>
          <div className="form-actions"><button className="button button-primary" type="submit"><PackagePlus size={16}/> Register delivery</button><button className="button button-plain" type="button" onClick={() => setPage('overview')}>Cancel</button></div>
        </form>
        <aside className="side-note"><div className="note-icon"><ShieldCheck size={19}/></div><h3>Why register your delivery?</h3><p>Pre-registering an order helps the gate team verify it when the delivery agent arrives.</p><ul><li>Keep your order ID handy.</li><li>Use the same ID shown by the delivery platform.</li><li>You can check the delivery status here anytime.</li></ul><p className="note-foot">This is a frontend demonstration. No real verification takes place.</p></aside>
      </div>
    </>;
  }

  function renderDeliveries() {
    return <>
      <div className="page-heading"><div><p className="eyebrow">DELIVERIES</p><h1>My deliveries</h1><p className="muted">View and manage the orders you have registered.</p></div><button className="button button-primary" onClick={() => setPage('register')}><PackagePlus size={16}/> Register delivery</button></div>
      <section className="content-card">
        <div className="toolbar"><div className="search-box"><Search size={16}/><input placeholder="Search by order ID or platform" value={query} onChange={e => setQuery(e.target.value)}/>{query && <button onClick={() => setQuery('')} aria-label="Clear search"><X size={14}/></button>}</div><select className="filter-select" value={filter} onChange={e => setFilter(e.target.value)}><option>All</option><option>Expected</option><option>Received</option><option>Expired</option></select></div>
        <DeliveryTable rows={filtered} empty="No deliveries match your search." />
      </section>
    </>;
  }

  function renderNotifications() {
    return <>
      <div className="page-heading"><div><p className="eyebrow">UPDATES</p><h1>Notifications</h1><p className="muted">Stay informed about your delivery activity.</p></div>{unread > 0 && <button className="button button-plain" onClick={markAllRead}>Mark all as read</button>}</div>
      <section className="content-card notification-list">
        {notifications.length === 0 ? <div className="empty-state"><Bell size={25}/><strong>You’re all caught up</strong><span>New delivery updates will appear here.</span></div> : notifications.map(n => <div className={`notification-row ${n.unread ? 'unread' : ''}`} key={n.id}><span className="notification-icon"><Bell size={17}/></span><div className="notification-copy"><div className="notification-title"><strong>{n.title}</strong>{n.unread && <span className="unread-dot"/>}</div><p>{n.body}</p><time>{n.time}</time></div><button className="small-action" onClick={() => setNotifications(curr => curr.map(x => x.id === n.id ? {...x, unread: !x.unread} : x))}>{n.unread ? 'Mark read' : 'Mark unread'}</button></div>)}
      </section>
    </>;
  }

  function renderProfile() {
    return <>
      <div className="page-heading"><div><p className="eyebrow">ACCOUNT</p><h1>Profile</h1><p className="muted">Your student account information.</p></div></div>
      <section className="content-card profile-card">
        <div className="profile-top"><div className="avatar">PG</div><div><h2>{profile.name}</h2><p className="muted">Student account</p></div></div>
        <div className="profile-fields">
          <label>Full name<input value={profile.name} onChange={e => setProfile({...profile,name:e.target.value})}/></label>
          <label>Roll number<input value={profile.roll} onChange={e => setProfile({...profile,roll:e.target.value})}/></label>
          <label>Email address<input type="email" value={profile.email} onChange={e => setProfile({...profile,email:e.target.value})}/></label>
          <label>Hostel / residence<input value={profile.hostel} onChange={e => setProfile({...profile,hostel:e.target.value})}/></label>
        </div>
        <div className="form-actions"><button className="button button-primary" onClick={() => notify('Profile changes saved locally')}>Save changes</button><span className="muted tiny">Changes are stored only in this page session.</span></div>
      </section>
    </>;
  }

  const titles = {
    overview: 'Overview',
    register: 'Register delivery',
    deliveries: 'My deliveries',
    notifications: 'Notifications',
    profile: 'Profile'
  };
  return <div className="app-shell">
    <aside className="sidebar">
      <Brand />
      <div className="sidebar-label">STUDENT MENU</div>
      <nav>{navItems.map(item => { const Icon = item.icon; return <button key={item.id} className={`nav-item ${page === item.id ? 'selected' : ''}`} onClick={() => setPage(item.id)}><Icon size={17}/><span>{item.label}</span>{item.id === 'notifications' && unread > 0 && <b className="nav-count">{unread}</b>}</button>; })}</nav>
      <div className="sidebar-bottom"><div className="help-link"><CircleHelp size={16}/><span>Need help?</span></div><div className="account-mini"><div className="mini-avatar">PG</div><div className="account-copy"><strong>Pratyush Gadge</strong><span>Student</span></div><button aria-label="Account options" onClick={() => setPage('profile')}><ChevronDown size={16}/></button></div></div>
    </aside>
    <main className="main-area">
      <header className="topbar"><div className="breadcrumb">Student portal <ChevronRight size={14}/> <strong>{titles[page]}</strong></div><div className="topbar-right"><span className="demo-label">DEMO DATA</span><button className="top-icon" aria-label="Notifications" onClick={() => setPage('notifications')}><Bell size={18}/>{unread > 0 && <i/>}</button><button className="top-profile" onClick={() => setPage('profile')}>PG</button></div></header>
      <div className="page-content">{page === 'overview' && renderOverview()}{page === 'register' && renderRegister()}{page === 'deliveries' && renderDeliveries()}{page === 'notifications' && renderNotifications()}{page === 'profile' && renderProfile()}<footer className="page-footer"><span>VoiceAuth</span><span>Student delivery portal · Frontend preview</span></footer></div>
    </main>
    {toast && <div className="toast"><Check size={16}/>{toast}</div>}
  </div>;
}

function DeliveryTable({ rows, empty = 'No deliveries to show.' }) {
  if (!rows.length) return <div className="empty-state"><Package size={25}/><strong>{empty}</strong><span>Try changing your search or filter.</span></div>;
  return <div className="table-wrap"><table><thead><tr><th>Order details</th><th>Platform</th><th>Expected date</th><th>Status</th></tr></thead><tbody>{rows.map(d => <tr key={d.id}><td><strong>{d.order}</strong><small>{d.id} · {d.item}</small></td><td>{d.platform}</td><td>{new Date(`${d.date}T00:00:00`).toLocaleDateString('en-IN',{day:'2-digit',month:'short',year:'numeric'})}</td><td><Status value={d.status}/></td></tr>)}</tbody></table></div>;
}

export default App;