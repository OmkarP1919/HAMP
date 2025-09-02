<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #1f2937;
            --secondary-color: #f9fafb;
            --accent-color: #2563eb;
            --light-text-color: #6b7280;
            --card-bg: #ffffff;
            --border-color: #e5e7eb;
            --success-color: #10b981;
            --warning-color: #f59e0b;
            --danger-color: #ef4444;
        }

        /* Basic reset and body styling */
        * {
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            margin: 0;
            background-color: var(--secondary-color);
            color: var(--primary-color);
            height: 100vh;
            display: grid;
            grid-template-rows: auto 1fr; /* Header row, content row */
            grid-template-columns: 260px 1fr; /* Sidebar col, main content col */
            grid-template-areas:
                "header header"
                "sidebar main";
        }

        /* --- UNCHANGED TEMPLATE STYLES --- */
        .top-panel {
            grid-area: header;
            background: linear-gradient(135deg, var(--accent-color), #4f87ff);
            color: #ffffff;
            padding: 1rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            z-index: 10;
        }
        .top-panel h1 { margin: 0; font-size: 1.8em; }
        .user-menu { display: flex; align-items: center; gap: 1.5rem; }
        .user-info { display: flex; align-items: center; gap: 0.75rem; font-weight: 500; }
        .user-info .fa-user-circle { font-size: 1.5rem; }
        .logout-btn {
            display: flex; align-items: center; gap: 0.5rem; background-color: rgba(255, 255, 255, 0.15);
            color: white; padding: 0.5rem 1rem; border-radius: 6px; text-decoration: none;
            font-weight: 500; transition: background-color 0.3s ease;
        }
        .logout-btn:hover { background-color: rgba(255, 255, 255, 0.25); }
        .side-panel {
            grid-area: sidebar; background-color: var(--card-bg); border-right: 1px solid var(--border-color);
            padding: 2rem; display: flex; flex-direction: column;
        }
        .side-panel h2 {
            font-size: 1.2rem; color: var(--primary-color); margin: 0 0 1.5rem 0;
            border-bottom: 1px solid var(--border-color); padding-bottom: 1rem;
        }
        .side-panel-nav { list-style: none; padding: 0; margin: 0; }
        .side-panel-nav li a {
            display: flex; align-items: center; gap: 1rem; padding: 0.8rem 1rem;
            margin-bottom: 0.5rem; text-decoration: none; color: var(--light-text-color);
            font-weight: 500; border-radius: 6px; transition: all 0.3s ease;
        }
        .side-panel-nav li a:hover { background-color: var(--secondary-color); color: var(--primary-color); }
        .side-panel-nav li a.active { background-color: var(--accent-color); color: white; font-weight: 600; }
        .side-panel-nav li a i { width: 20px; text-align: center; }

        /* --- NEW ADMIN DASHBOARD STYLES --- */
        .main-content {
            grid-area: main;
            padding: 2.5rem;
            overflow-y: auto;
        }

        .welcome-banner {
            background: linear-gradient(100deg, #3b82f6, #60a5fa);
            color: white;
            padding: 2rem;
            border-radius: 12px;
            margin-bottom: 2.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .welcome-banner h2 { font-size: 1.8rem; margin: 0; font-weight: 700; }
        .welcome-banner p { margin: 0.25rem 0 0; opacity: 0.9; }
        .date-display {
            background-color: rgba(255,255,255,0.2);
            padding: 0.75rem 1.25rem;
            border-radius: 8px;
            font-weight: 600;
            text-align: center;
        }
        .date-display .label { font-size: 0.8rem; opacity: 0.8; }
        .date-display .date { font-size: 1.1rem; }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2.5rem;
        }
        .stat-card {
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 1.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .stat-card .number { font-size: 2rem; font-weight: 800; }
        .stat-card .label { font-size: 1rem; color: var(--light-text-color); font-weight: 500; }
        .stat-card .icon-wrapper {
            width: 50px; height: 50px;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.5rem;
        }
        .icon-students { background-color: #e0e7ff; color: #3730a3; }
        .icon-rooms { background-color: #d1fae5; color: #047857; }
        .icon-fees { background-color: #fef3c7; color: #b45309; }
        .icon-apps { background-color: #fee2e2; color: #b91c1c; }

        .activity-card {
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 12px;
        }
        .activity-header { padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border-color); }
        .activity-header h2 { margin: 0; font-size: 1.2rem; font-weight: 600; }
        .activity-list { list-style: none; padding: 0; margin: 0; }
        .activity-item {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid var(--border-color);
        }
        .activity-item:last-child { border-bottom: none; }
        /* NEW rule to fix icon alignment */
        .activity-item .icon-wrapper {
            width: 40px;
            height: 40px;
            flex-shrink: 0; /* Prevents the icon from shrinking */
            font-size: 1rem;
        }
        .activity-item .details { flex-grow: 1; }
        .activity-item .title { font-weight: 600; }
        .activity-item .description { color: var(--light-text-color); font-size: 0.9rem; }
        .activity-item .time { color: var(--light-text-color); font-size: 0.9rem; white-space: nowrap; }

        /* Responsive */
        @media (max-width: 992px) {
            body { grid-template-columns: 1fr; grid-template-rows: auto auto 1fr; grid-template-areas: "header" "sidebar" "main"; }
            .side-panel { border-right: none; border-bottom: 1px solid var(--border-color); }
        }
        @media (max-width: 768px) {
            .welcome-banner { flex-direction: column; align-items: flex-start; gap: 1rem; }
        }
    </style>
</head>
<body>
    <header class="top-panel">
        <div class="logo-title"><h1>Hostel Mate</h1></div>
        <div class="user-menu">
            <span class="user-info"><i class="fas fa-user-circle"></i> Welcome, Admin</span>
            <a href="#" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
        </div>
    </header>
    <aside class="side-panel">
        <h2>Admin Menu</h2>
        <ul class="side-panel-nav">
            <li><a href="#" class="active"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
            <li><a href="#"><i class="fas fa-user-cog"></i> Profile</a></li>
            <li><a href="#"><i class="fas fa-file-signature"></i> Applications</a></li>
            <li><a href="#"><i class="fas fa-users"></i> Students</a></li>
            <li><a href="#"><i class="fas fa-bed"></i> Rooms</a></li>
        </ul>
    </aside>
    <main class="main-content">
        <div class="welcome-banner">
            <div>
                <h2>Welcome back, Admin!</h2>
                <p>Here's what's happening in your hostel today.</p>
            </div>
            <div class="date-display">
                <div class="label">TODAY'S DATE</div>
                <div class="date">January 15, 2024</div>
            </div>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div>
                    <div class="number">248</div>
                    <div class="label">Total Students</div>
                </div>
                <div class="icon-wrapper icon-students"><i class="fas fa-users"></i></div>
            </div>
            <div class="stat-card">
                <div>
                    <div class="number">12</div>
                    <div class="label">Available Rooms</div>
                </div>
                <div class="icon-wrapper icon-rooms"><i class="fas fa-bed"></i></div>
            </div>
            <div class="stat-card">
                <div>
                    <div class="number">?45,000</div>
                    <div class="label">Pending Fees</div>
                </div>
                <div class="icon-wrapper icon-fees"><i class="fas fa-exclamation-triangle"></i></div>
            </div>
            <div class="stat-card">
                <div>
                    <div class="number">12</div>
                    <div class="label">New Applications</div>
                </div>
                <div class="icon-wrapper icon-apps"><i class="fas fa-file-alt"></i></div>
            </div>
        </div>

        <div class="activity-card">
            <div class="activity-header"><h2>Last Activity</h2></div>
            <ul class="activity-list">
                <!-- Inline styles removed for proper alignment -->
                <li class="activity-item">
                    <div class="icon-wrapper icon-students"><i class="fas fa-user-plus"></i></div>
                    <div class="details">
                        <div class="title">New student registration</div>
                        <div class="description">John Doe applied for Room 204</div>
                    </div>
                    <div class="time">2 hours ago</div>
                </li>
                 <li class="activity-item">
                    <div class="icon-wrapper icon-rooms"><i class="fas fa-file-invoice-dollar"></i></div>
                    <div class="details">
                        <div class="title">Fee payment received</div>
                        <div class="description">Sarah Smith paid ?15,000 for Room 301</div>
                    </div>
                    <div class="time">4 hours ago</div>
                </li>
                 <li class="activity-item">
                    <div class="icon-wrapper icon-fees"><i class="fas fa-bed"></i></div>
                    <div class="details">
                        <div class="title">Room maintenance completed</div>
                        <div class="description">Room 105 is now available for booking</div>
                    </div>
                    <div class="time">6 hours ago</div>
                </li>
                 <li class="activity-item">
                    <div class="icon-wrapper icon-apps"><i class="fas fa-exclamation-triangle"></i></div>
                    <div class="details">
                        <div class="title">Fee payment overdue</div>
                        <div class="description">Mike Johnson's payment is 3 days overdue</div>
                    </div>
                    <div class="time">1 day ago</div>
                </li>
            </ul>
        </div>
    </main>
</body>
</html>

