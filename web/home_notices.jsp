<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notices & Downloads</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #1f2937 
            --secondary-color: #f9fafb;
            --accent-color: #2563eb;
            --light-text-color: #6b7280;
            --card-bg: #ffffff;
            --border-color: #e5e7eb;
            --card-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
        }

        /* General Body and Container Styling */
        body {
            font-family: 'Inter', sans-serif;
            margin: 0;
            padding: 0;
            background-color: var(--secondary-color);
            color: var(--primary-color);
        }

        .container {
            max-width: 1200px; /* Wider container for side-by-side layout */
            margin: 0 auto;
            padding: 0 1rem;
        }

        /* --- Top Panel Styling --- */
        .top-panel {
            background: linear-gradient(135deg, var(--accent-color), #4f87ff);
            color: #ffffff;
            padding: 20px;
            text-align: center;
        }

        .top-panel h1 {
            margin: 0;
            font-size: 2.5em;
        }

        .navbar ul {
            list-style-type: none;
            margin: 15px 0 0;
            padding: 0;
        }

        .navbar li {
            display: inline-block;
            margin: 0 10px;
        }

        .navbar a {
            color: #ffffff;
            opacity: 0.9;
            text-decoration: none;
            font-size: 1.1em;
            padding: 8px 15px;
            border-radius: 5px;
            transition: all 0.3s ease;
        }

        .navbar a:hover {
            opacity: 1;
            background-color: rgba(255, 255, 255, 0.15);
        }
        /* --- CORRECTED DROPDOWN STYLES --- */
        .dropdown {
            position: relative;
            display: inline-block;
        }
        .dropdown .dropbtn {
            display: flex; /* Ensures caret is aligned */
            align-items: center;
            gap: 0.5rem; /* Space between text and icon */
            cursor: pointer;
            /* Inherits padding, color, etc. from .navbar a */
        }
        .dropdown-content {
            display: none;
            position: absolute;
            background-color: var(--card-bg);
            min-width: 180px;
            box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.1);
            z-index: 1;
            border-radius: 8px;
            /* Important fix: removed margin-top to prevent gap */
            top: 100%; /* Position right below the button */
            left: 0; /* Align left with the button */
            padding-top: 0.5rem; /* Visual space but still part of dropdown hover area */
            overflow: hidden;
        }
        .dropdown-content a {
            color: var(--primary-color);
            padding: 10px 16px; /* Adjusted padding for dropdown items */
            text-decoration: none;
            display: block;
            text-align: left;
            font-weight: 500;
            background-color: transparent;
            opacity: 1;
            white-space: nowrap; /* Prevent items from wrapping */
        }
        .dropdown-content a:hover {
            background-color: var(--secondary-color);
        }
        .dropdown:hover .dropdown-content {
            display: block;
        }
        
        /* Main Content Styling */
        .main-content {
            padding: 4rem 0;
        }
        
        /* NEW Wrapper for side-by-side sections */
        .content-wrapper {
            display: grid;
            grid-template-columns: 1fr 1fr; /* Two equal columns */
            gap: 3rem; /* Space between columns */
            align-items: start;
        }

        /* Section Title Styling */
        .section-title {
            font-size: 2rem;
            font-weight: 700;
            text-align: left; /* Aligned left for column layout */
            color: var(--primary-color);
            margin-bottom: 2rem;
            position: relative;
        }
        .section-title::after {
            content: '';
            display: block;
            width: 50px;
            height: 4px;
            background-color: var(--accent-color);
            margin: 0.5rem 0 0; /* Aligned left */
            border-radius: 2px;
        }

        /* Notices Section Styling */
        .notices-section {
            margin-bottom: 4rem;
        }

        .notice-card {
            background-color: var(--card-bg);
            border-radius: 10px;
            padding: 1.5rem 2rem;
            margin-bottom: 1.5rem;
            box-shadow: var(--card-shadow);
            border-left: 5px solid var(--accent-color);
        }

        .notice-card h3 {
            margin: 0 0 0.5rem;
            font-size: 1.25rem;
            color: var(--primary-color);
        }

        .notice-meta {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.9rem;
            color: var(--light-text-color);
            margin-bottom: 1rem;
        }

        .notice-meta i {
            width: 16px;
        }

        .notice-card p {
            margin: 0;
            line-height: 1.6;
            color: #374151;
        }

        /* Downloads Section Styling */
        .download-list {
            list-style: none;
            padding: 0;
        }

        .download-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background-color: var(--card-bg);
            padding: 1rem 1.5rem;
            border-radius: 8px;
            margin-bottom: 1rem;
            box-shadow: var(--card-shadow);
            border: 1px solid var(--border-color);
            transition: all 0.3s ease;
        }
        
        .download-item:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 15px rgba(0,0,0,0.07);
        }

        .file-info {
            display: flex;
            align-items: center;
            gap: 1rem;
            font-weight: 500;
        }

        .file-info i {
            font-size: 1.5rem;
            color: #ef4444; /* PDF red color */
        }
        
        .btn-download {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            background-color: var(--accent-color);
            color: white;
            padding: 0.6rem 1.2rem;
            text-decoration: none;
            border-radius: 6px;
            font-weight: 600;
            transition: background-color 0.3s ease;
        }
        
        .btn-download:hover {
            background-color: #1e40af;
        }

        /* Responsive Design */
        @media (max-width: 992px) {
            .content-wrapper {
                grid-template-columns: 1fr; /* Stack columns */
            }
            .section-title {
                text-align: center; /* Center titles when stacked */
            }
            .section-title::after {
                margin: 0.5rem auto 0; /* Center underline */
            }
        }

    </style>
</head>
<body>

    <header class="top-panel">
        <h1>Hostel Mate</h1>
        <nav class="navbar">
                <ul>
                    <li><a href="index.html">Home</a></li>
                    <!-- UPDATED LOGIN DROPDOWN -->
                    <li class="dropdown">
                        <a href="#" class="dropbtn">Login <i class="fas fa-caret-down fa-xs"></i></a>
                        <div class="dropdown-content">
                            <a href="user_login.jsp">Student</a>
                            <a href="admin_login.jsp">Admin</a>
                        </div>
                    </li>
                    <li><a href="home_hostels.jsp">Hostels</a></li>
                    <li><a href="user_register.jsp">Apply</a></li>
                    <li><a href="home_notices.jsp">Downloads</a></li>
                    <li><a href="#">Contact Us</a></li>
                </ul>
            </nav>
    </header>

    <main class="main-content">
        <div class="container">
            <div class="content-wrapper">
                
                <section class="notices-section">
                    <h2 class="section-title">Notice Board</h2>
                    <div class="notice-card">
                        <h3>Hostel Allotment List for 2nd Year Students</h3>
                        <div class="notice-meta">
                            <i class="fas fa-calendar-alt"></i>
                            <span>Posted on: August 28, 2025</span>
                        </div>
                        <p>The final list for hostel room allotment for second-year undergraduate students has been published. Please check the downloads section for the complete list.</p>
                    </div>
                    <div class="notice-card">
                        <h3>Mess Fee Payment Deadline Extended</h3>
                        <div class="notice-meta">
                            <i class="fas fa-calendar-alt"></i>
                            <span>Posted on: August 25, 2025</span>
                        </div>
                        <p>The deadline for mess fee payment for the upcoming semester has been extended to September 10, 2025. No further extensions will be provided.</p>
                    </div>
                </section>
    
                <section class="downloads-section">
                    <h2 class="section-title">Downloads</h2>
                    <ul class="download-list">
                        <li class="download-item">
                            <div class="file-info">
                                <i class="fas fa-file-pdf"></i>
                                <span>Fee Structure 2025-2026</span>
                            </div>
                            <a href="#" class="btn-download"><i class="fas fa-download"></i> Download</a>
                        </li>
                        <li class="download-item">
                            <div class="file-info">
                                <i class="fas fa-file-pdf"></i>
                                <span>Hostel Rulebook</span>
                            </div>
                            <a href="#" class="btn-download"><i class="fas fa-download"></i> Download</a>
                        </li>
                        <li class="download-item">
                            <div class="file-info">
                                <i class="fas fa-file-pdf"></i>
                                <span>Anti-Ragging Affidavit Form</span>
                            </div>
                            <a href="#" class="btn-download"><i class="fas fa-download"></i> Download</a>
                        </li>
                        <li class="download-item">
                            <div class="file-info">
                                <i class="fas fa-file-pdf"></i>
                                <span>Hostel Allotment List (2nd Year)</span>
                            </div>
                            <a href="#" class="btn-download"><i class="fas fa-download"></i> Download</a>
                        </li>
                    </ul>
                </section>

            </div>
        </div>
    </main>

</body>
</html>