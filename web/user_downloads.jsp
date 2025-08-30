<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Template</title>
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

        /* --- Top Panel Styling --- */
        .top-panel {
            grid-area: header;
            background: linear-gradient(135deg, var(--accent-color), #4f87ff);
            color: #ffffff;
            padding: 1rem 2rem; /* Adjusted padding */
            display: flex; /* Changed to flex for alignment */
            justify-content: space-between; /* Pushes items to ends */
            align-items: center; /* Vertically aligns items */
            z-index: 10;
        }

        .top-panel h1 {
            margin: 0;
            font-size: 1.8em; /* Slightly adjusted font size */
        }
        
        /* New User Menu Styling */
        .user-menu {
            display: flex;
            align-items: center;
            gap: 1.5rem;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            font-weight: 500;
        }
        
        .user-info .fa-user-circle {
            font-size: 1.5rem;
        }

        .logout-btn {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            background-color: rgba(255, 255, 255, 0.15);
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 6px;
            text-decoration: none;
            font-weight: 500;
            transition: background-color 0.3s ease;
        }
        
        .logout-btn:hover {
            background-color: rgba(255, 255, 255, 0.25);
        }

        /* --- Side Panel Styling --- */
        .side-panel {
            grid-area: sidebar;
            background-color: var(--card-bg);
            border-right: 1px solid var(--border-color);
            padding: 2rem;
            display: flex;
            flex-direction: column;
        }

        .side-panel h2 {
            font-size: 1.2rem;
            color: var(--primary-color);
            margin: 0 0 1.5rem 0;
            border-bottom: 1px solid var(--border-color);
            padding-bottom: 1rem;
        }

        .side-panel-nav {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .side-panel-nav li a {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 0.8rem 1rem;
            margin-bottom: 0.5rem;
            text-decoration: none;
            color: var(--light-text-color);
            font-weight: 500;
            border-radius: 6px;
            transition: all 0.3s ease;
        }

        .side-panel-nav li a:hover {
            background-color: var(--secondary-color);
            color: var(--primary-color);
        }

        .side-panel-nav li a.active {
            background-color: var(--accent-color);
            color: white;
            font-weight: 600;
        }
        
        .side-panel-nav li a i {
            width: 20px;
            text-align: center;
        }

        /* Main Content Styling */
        .main-content {
            grid-area: main;
            padding: 2.5rem;
            overflow-y: auto;
        }

        .main-content h1 {
            margin-top: 0;
            font-size: 2rem;
            color: var(--primary-color);
        }

        .main-content p {
            line-height: 1.6;
            color: var(--light-text-color);
        }

        /* Responsive Design */
        @media (max-width: 992px) {
            body {
                grid-template-columns: 1fr; /* Single column */
                grid-template-rows: auto auto 1fr; /* Header, Sidebar, Main */
                grid-template-areas:
                    "header"
                    "sidebar"
                    "main";
            }
            .side-panel {
                border-right: none;
                border-bottom: 1px solid var(--border-color);
            }
        }
        
        @media (max-width: 600px) {
            .top-panel {
                flex-direction: column;
                gap: 1rem;
            }
        }
    </style>
</head>
<body>

    <header class="top-panel">
        <div class="logo-title">
            <h1>Hostel Mate</h1>
        </div>
        <div class="user-menu">
            <span class="user-info">
                <i class="fas fa-user-circle"></i> Welcome, Alex
            </span>
            <a href="#" class="logout-btn">
                <i class="fas fa-sign-out-alt"></i> Logout
            </a>
        </div>
    </header>

    <aside class="side-panel">
        <h2>Student Menu</h2>
        <ul class="side-panel-nav">
            <li><a href="#" class="active"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
            <li><a href="#"><i class="fas fa-file-alt"></i> Apply</a></li>
            <li><a href="#"><i class="fas fa-user-circle"></i> Profile</a></li>
            <li><a href="#"><i class="fas fa-download"></i> Downloads</a></li>
            <li><a href="#"><i class="fas fa-file-invoice-dollar"></i> Payments</a></li>
            <li><a href="#"><i class="fas fa-check-circle"></i> Status</a></li>
        </ul>
    </aside>

    <main class="main-content">
        <h1>Dashboard</h1>
        <p>This is where your main page content will go. You can add forms, tables, text, images, or any other elements here.</p>
        <p>The layout is fully responsive. On smaller screens, the side panel will stack above this main content area.</p>
    </main>

</body>
</html>