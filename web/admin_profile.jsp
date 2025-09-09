<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Profile</title>
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

        /* --- ADMIN PROFILE PAGE STYLES --- */
        .main-content {
            grid-area: main;
            padding: 2.5rem;
            overflow-y: auto;
        }
        
        .page-header h1 {
            font-size: 2rem;
            font-weight: 800;
            margin: 0 0 2.5rem 0;
        }

        .card {
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            margin-bottom: 2rem;
        }

        .card-header {
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid var(--border-color);
        }
        .card-header h2 { margin: 0; font-size: 1.2rem; font-weight: 600; }

        .card-body { padding: 1.5rem; }

        .profile-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }
        .form-group:last-child { margin-bottom: 0; }

        .form-group label {
            display: block;
            font-size: 0.9rem;
            color: var(--light-text-color);
            font-weight: 500;
            margin-bottom: 0.5rem;
        }

        .form-group input {
            width: 100%;
            padding: 0.75rem 1rem;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            font-size: 1rem;
            font-family: 'Inter', sans-serif;
        }
        
        .form-group .value {
             font-size: 1rem;
            font-weight: 600;
            padding: 0.75rem 1rem;
            background-color: var(--secondary-color);
            border-radius: 6px;
            border: 1px solid var(--border-color);
        }

        .card-footer {
            padding: 1.25rem 1.5rem;
            border-top: 1px solid var(--border-color);
            background-color: var(--secondary-color);
            text-align: right;
            border-radius: 0 0 12px 12px;
        }

        .button-save {
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 8px;
            background-color: var(--accent-color);
            color: white;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.2s ease;
        }
        .button-save:hover { background-color: #1d4ed8; }
        
        /* Responsive */
        @media (max-width: 992px) {
            body { grid-template-columns: 1fr; grid-template-rows: auto auto 1fr; grid-template-areas: "header" "sidebar" "main"; }
            .side-panel { border-right: none; border-bottom: 1px solid var(--border-color); }
        }
    </style>
</head>
<body>
    <header class="top-panel">
        <div class="logo-title"><h1>Hostel Mate</h1></div>
        <div class="user-menu">
            <span class="user-info"><i class="fas fa-user-circle"></i> Welcome, Admin</span>
            <a href="admin_login.jsp" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
        </div>
    </header>
    <aside class="side-panel">
        <h2>Admin Menu</h2>
        <ul class="side-panel-nav">
            <li><a href="admin_dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
            <li><a href="#"><i class="fas fa-user-cog"></i> Profile</a></li>
            <li><a href="admin_applications.jsp" class="active"><i class="fas fa-file-signature"></i> Applications</a></li>
            <li><a href="admin_slist.jsp"><i class="fas fa-users"></i> Students</a></li>
            <li><a href="admin_rooms.jsp"><i class="fas fa-bed"></i> Rooms</a></li>
        </ul>
    </aside>
    <main class="main-content">
        <div class="page-header">
            <h1>Admin Profile</h1>
        </div>

        <!-- Admin Information Card -->
        <div class="card">
            <div class="card-header">
                <h2>Admin Information</h2>
            </div>
            <div class="card-body">
                <div class="profile-grid">
                    <div class="form-group">
                        <label>Full Name</label>
                        <div class="value">Admin Name</div>
                    </div>
                    <div class="form-group">
                        <label>Admin ID / Rector ID</label>
                        <div class="value">RECTOR-A</div>
                    </div>
                    <div class="form-group">
                        <label>Email Address</label>
                        <div class="value">admin@example.com</div>
                    </div>
                    <div class="form-group">
                        <label>Hostel Managed</label>
                        <div class="value">Hostel A</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Change Password Card -->
        <div class="card">
            <div class="card-header">
                <h2>Change Password</h2>
            </div>
            <form action="update_admin_password.jsp" method="POST">
                <div class="card-body">
                    <div class="profile-grid">
                        <div class="form-group">
                            <label for="old_password">Old Password</label>
                            <input type="password" id="old_password" name="old_password" required>
                        </div>
                        <div class="form-group">
                            <label for="new_password">New Password</label>
                            <input type="password" id="new_password" name="new_password" required>
                        </div>
                        <div class="form-group">
                            <label for="confirm_password">Confirm New Password</label>
                            <input type="password" id="confirm_password" name="confirm_password" required>
                        </div>
                    </div>
                </div>
                <div class="card-footer">
                    <button type="submit" class="button-save">Update Password</button>
                </div>
            </form>
        </div>
    </main>
</body>
</html>
