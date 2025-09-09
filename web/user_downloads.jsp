<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Downloads</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
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

        /* --- NEW DOWNLOADS PAGE STYLES --- */
        .main-content {
            grid-area: main;
            padding: 2.5rem;
            overflow-y: auto;
        }

        .page-header h1 {
            margin: 0 0 2rem 0;
            font-size: 2rem;
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

        .card-header h2 {
            margin: 0;
            font-size: 1.2rem;
            font-weight: 600;
        }

        .download-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .download-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid var(--border-color);
        }

        .download-item:last-child {
            border-bottom: none;
        }
        
        .download-info {
            display: flex;
            align-items: center;
            gap: 1.5rem;
        }

        .download-info .icon {
            font-size: 1.5rem;
            color: var(--accent-color);
            width: 30px;
            text-align: center;
        }
        
        .download-info .title {
            font-weight: 600;
            font-size: 1rem;
        }
        
        .download-info .description {
            font-size: 0.9rem;
            color: var(--light-text-color);
            margin-top: 0.25rem;
        }
        
        .button-download {
            padding: 0.6rem 1.2rem;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            font-size: 0.9rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            background-color: var(--card-bg);
            color: var(--primary-color);
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .button-download:hover {
            background-color: var(--secondary-color);
            border-color: #d1d5db;
        }

        .button-download.disabled {
            background-color: var(--secondary-color);
            color: var(--light-text-color);
            cursor: not-allowed;
            border-color: var(--border-color);
        }

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
            <li><a href="user_dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
            <li><a href="user_apply.jsp" class="active"><i class="fas fa-file-alt"></i> Apply</a></li>
            <li><a href="user_profile.jsp"><i class="fas fa-user-circle"></i> Profile</a></li>
            <li><a href="#"><i class="fas fa-download"></i> Downloads</a></li>
            <li><a href="user_payfees.jsp"><i class="fas fa-file-invoice-dollar"></i> Payments</a></li>
            <li><a href="user_status.jsp"><i class="fas fa-check-circle"></i> Status</a></li>
        </ul>
    </aside>

    <main class="main-content">
        <div class="page-header">
            <h1>Downloads</h1>
        </div>

        <!-- Personal Documents Card -->
        <div class="card">
            <div class="card-header"><h2>My Documents</h2></div>
            <ul class="download-list">
                <!-- JSP logic will control what's shown here -->
                <li class="download-item">
                    <div class="download-info">
                        <i class="fas fa-file-alt icon"></i>
                        <div>
                            <div class="title">Hostel Application Form</div>
                            <div class="description">Your submitted application for the current academic year.</div>
                        </div>
                    </div>
                    <!-- Example: Enabled button if form is available -->
                    <a href="download-servlet?type=application" class="button-download"><i class="fas fa-download"></i> Download</a>
                </li>
                <li class="download-item">
                    <div class="download-info">
                        <i class="fas fa-file-invoice-dollar icon"></i>
                        <div>
                            <div class="title">Fee Payment Receipt</div>
                            <div class="description">Official receipt for your hostel fee payment.</div>
                        </div>
                    </div>
                    <!-- Example: Disabled button if payment is not yet made -->
                    <a href="#" class="button-download disabled" aria-disabled="true">Available after payment</a>
                </li>
            </ul>
        </div>

        <!-- General Documents Card -->
        <div class="card">
            <div class="card-header"><h2>General Documents</h2></div>
            <ul class="download-list">
                <li class="download-item">
                    <div class="download-info">
                        <i class="fas fa-book icon"></i>
                        <div>
                            <div class="title">Hostel Rulebook 2025-26</div>
                            <div class="description">Rules and regulations for all hostel residents.</div>
                        </div>
                    </div>
                    <a href="downloads/Hostel-Rulebook.pdf" class="button-download"><i class="fas fa-download"></i> Download</a>
                </li>
                <li class="download-item">
                    <div class="download-info">
                        <i class="fas fa-calendar-alt icon"></i>
                        <div>
                            <div class="title">Academic Calendar</div>
                            <div class="description">Important dates and holidays for the current semester.</div>
                        </div>
                    </div>
                    <a href="downloads/Academic-Calendar.pdf" class="button-download"><i class="fas fa-download"></i> Download</a>
                </li>
                 <li class="download-item">
                    <div class="download-info">
                        <i class="fas fa-info-circle icon"></i>
                        <div>
                            <div class="title">Fee Structure Details</div>
                            <div class="description">A detailed breakdown of the hostel fee components.</div>
                        </div>
                    </div>
                    <a href="downloads/Fee-Structure.pdf" class="button-download"><i class="fas fa-download"></i> Download</a>
                </li>
            </ul>
        </div>
    </main>
</body>
</html>
