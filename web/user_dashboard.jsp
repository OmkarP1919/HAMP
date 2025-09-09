<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard</title>
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
            grid-template-rows: auto 1fr;
            grid-template-columns: 260px 1fr;
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

        /* --- NEW DASHBOARD STYLES --- */
        .main-content {
            grid-area: main;
            padding: 2.5rem;
            overflow-y: auto;
        }
        
        .dashboard-header {
            margin-bottom: 2rem;
        }
        
        .dashboard-header h1 {
            font-size: 2.2rem;
            font-weight: 800;
            margin: 0;
        }
        
        .dashboard-header p {
            font-size: 1.1rem;
            color: var(--light-text-color);
            margin-top: 0.5rem;
        }

        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2.5rem;
        }

        .action-card {
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 1.5rem;
            text-decoration: none;
            color: var(--primary-color);
            transition: all 0.2s ease-in-out;
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        
        .action-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.08);
            border-color: var(--accent-color);
        }

        .action-card .icon {
            font-size: 1.8rem;
            color: var(--accent-color);
        }

        .action-card .title {
            font-size: 1.1rem;
            font-weight: 600;
        }

        .status-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2.5rem;
        }

        .status-card {
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 1.5rem;
        }
        
        .status-card-header {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            color: var(--light-text-color);
            font-weight: 500;
            margin-bottom: 1rem;
        }
        
        .status-card-body .status-text {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 1rem;
        }
        
        /* Status-specific colors */
        .status-text.approved { color: var(--success-color); }
        .status-text.pending { color: var(--warning-color); }
        .status-text.rejected { color: var(--danger-color); }
        .status-text.incomplete { color: var(--danger-color); }

        .status-card-footer a {
            color: var(--accent-color);
            font-weight: 600;
            text-decoration: none;
        }

        .card {
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 12px;
        }
        .card-header { padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border-color); }
        .card-header h2 { margin: 0; font-size: 1.2rem; font-weight: 600; }
        .card-body { padding: 1.5rem; }
        
        .details-grid {
             display: grid;
             grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
             gap: 1.5rem;
        }
        .detail-item .label { font-size: 0.9rem; color: var(--light-text-color); }
        .detail-item .value { font-size: 1.1rem; font-weight: 600; margin-top: 0.25rem; }


        /* Responsive Design */
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
            <span class="user-info"><i class="fas fa-user-circle"></i> Welcome, Alex</span>
            <a href="user_login.jsp" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
        </div>
    </header>

    <aside class="side-panel">
        <h2>Student Menu</h2>
        <ul class="side-panel-nav">
            <li><a href="#" class="active"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
            <li><a href="user_apply.jsp"><i class="fas fa-file-alt"></i> Apply</a></li>
            <li><a href="user_profile.jsp"><i class="fas fa-user-circle"></i> Profile</a></li>
            <li><a href="user_downloads.jsp"><i class="fas fa-download"></i> Downloads</a></li>
            <li><a href="user_payfees.jsp"><i class="fas fa-file-invoice-dollar"></i> Payments</a></li>
            <li><a href="user_status.jsp"><i class="fas fa-check-circle"></i> Status</a></li>
        </ul>
    </aside>

    <main class="main-content">
        <div class="dashboard-header">
            <!-- JSP will populate the student's name -->
            <h1>Welcome back, Alex!</h1>
            <p>Here's an overview of your hostel application status and actions.</p>
        </div>

        <!-- Quick Actions -->
        <div class="quick-actions">
            <a href="user_apply.jsp" class="action-card">
                <i class="fas fa-file-signature icon"></i>
                <div>
                    <span class="title">Apply for Hostel</span>
                </div>
            </a>
            <a href="user_payfees.jsp" class="action-card">
                <i class="fas fa-credit-card icon"></i>
                <div>
                    <span class="title">Pay Fees</span>
                </div>
            </a>
        </div>

        <!-- Status Overview -->
        <div class="status-grid">
            <div class="status-card">
                <div class="status-card-header"><i class="fas fa-user"></i><span>Profile Status</span></div>
                <div class="status-card-body">
                    <!-- JSP Logic: Check if profile is complete -->
                    <div class="status-text incomplete">Incomplete</div>
                    <p class="status-description">Please complete your profile to apply for a hostel.</p>
                </div>
                <div class="status-card-footer">
                    <a href="user_profile.jsp">Update Profile &rarr;</a>
                </div>
            </div>
            <div class="status-card">
                <div class="status-card-header"><i class="fas fa-file-alt"></i><span>Application Status</span></div>
                <div class="status-card-body">
                    <!-- JSP Logic: Show application status (e.g., Pending, Approved, Rejected) -->
                    <div class="status-text pending">Pending</div>
                     <p class="status-description">Your application is under review by the administration.</p>
                </div>
                <div class="status-card-footer">
                    <a href="user_status.jsp">Check Details &rarr;</a>
                </div>
            </div>
            <div class="status-card">
                <div class="status-card-header"><i class="fas fa-dollar-sign"></i><span>Payment Status</span></div>
                <div class="status-card-body">
                    <!-- JSP Logic: Show payment status (e.g., Paid, Unpaid) -->
                    <div class="status-text approved">Paid</div>
                    <p class="status-description">Your fee payment has been successfully received.</p>
                </div>
                <div class="status-card-footer">
                    <a href="user_payfees.jsp">View History &rarr;</a>
                </div>
            </div>
        </div>

        <!-- Room Allocation Details (Conditional) -->
        <!-- JSP Logic: Only show this card if application status is 'Approved' and a room is allocated -->
        <div class="card">
            <div class="card-header"><h2>Your Room Allocation</h2></div>
            <div class="card-body">
                <div class="details-grid">
                    <div class="detail-item">
                        <div class="label">Hostel Block</div>
                        <div class="value">A</div>
                    </div>
                    <div class="detail-item">
                        <div class="label">Floor Number</div>
                        <div class="value">3rd Floor</div>
                    </div>
                    <div class="detail-item">
                        <div class="label">Room Number</div>
                        <div class="value">A-302</div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</body>
</html>
