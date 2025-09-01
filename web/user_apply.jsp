<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apply for Hostel</title>
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

        /* --- NEW APPLY PAGE STYLES --- */
        .main-content {
            grid-area: main;
            padding: 2.5rem;
            overflow-y: auto;
            display: flex;
            justify-content: center;
        }
        
        .apply-container {
            width: 100%;
            max-width: 800px;
        }

        .page-header h1 {
            font-size: 2rem;
            font-weight: 800;
            margin: 0 0 0.5rem 0;
        }
        
        .page-header p {
            font-size: 1.1rem;
            color: var(--light-text-color);
            margin-bottom: 2.5rem;
        }

        .card {
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        }

        .card-header {
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid var(--border-color);
        }
        .card-header h2 { margin: 0; font-size: 1.2rem; font-weight: 600; }

        .card-body { padding: 2rem 1.5rem; }
        .card-footer {
            padding: 1.25rem 1.5rem;
            border-top: 1px solid var(--border-color);
            background-color: var(--secondary-color);
            border-radius: 0 0 12px 12px;
        }

        .details-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        .detail-item .label {
            font-size: 0.9rem;
            color: var(--light-text-color);
            font-weight: 500;
            margin-bottom: 0.25rem;
        }
        .detail-item .value {
            font-size: 1rem;
            font-weight: 600;
            padding: 0.75rem 1rem;
            background-color: var(--secondary-color);
            border-radius: 6px;
            border: 1px solid var(--border-color);
        }
        
        .declaration {
            display: flex;
            align-items: flex-start;
            gap: 0.75rem;
        }
        .declaration input[type="checkbox"] {
            margin-top: 5px;
            width: 1.2em;
            height: 1.2em;
        }
        .declaration label {
            font-size: 1rem;
            line-height: 1.6;
            color: var(--light-text-color);
        }
        .declaration label a {
            color: var(--accent-color);
            font-weight: 600;
            text-decoration: none;
        }
        
        .button-submit {
            width: 100%;
            padding: 1rem;
            border: none;
            border-radius: 8px;
            background-color: var(--accent-color);
            color: white;
            font-size: 1.1rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .button-submit:disabled {
            background-color: #9ca3af;
            cursor: not-allowed;
        }
        .button-submit:hover:not(:disabled) {
            background-color: #1d4ed8;
        }

        /* Styles for alert/notice boxes */
        .notice-box {
            padding: 1.5rem;
            border-radius: 12px;
            border: 1px solid;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
        }
        .notice-box i { font-size: 2.5rem; margin-bottom: 1rem; }
        .notice-box h2 { margin: 0 0 0.5rem 0; font-size: 1.5rem; }
        .notice-box p { margin: 0 0 1.5rem 0; font-size: 1.1rem; color: var(--light-text-color); max-width: 500px; }
        .notice-box a {
            background-color: var(--primary-color); color: white; padding: 0.8rem 2rem;
            border-radius: 8px; text-decoration: none; font-weight: 600;
        }
        .notice-profile { border-color: #f59e0b; background-color: #fffbeb; color: #92400e; }
        .notice-applied { border-color: #10b981; background-color: #f0fdf4; color: #065f46; }

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
            <span class="user-info"><i class="fas fa-user-circle"></i> Welcome, Alex</span>
            <a href="#" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
        </div>
    </header>

    <aside class="side-panel">
        <h2>Student Menu</h2>
        <ul class="side-panel-nav">
            <li><a href="#"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
            <li><a href="#" class="active"><i class="fas fa-file-alt"></i> Apply</a></li>
            <li><a href="#"><i class="fas fa-user-circle"></i> Profile</a></li>
            <li><a href="#"><i class="fas fa-download"></i> Downloads</a></li>
            <li><a href="#"><i class="fas fa-file-invoice-dollar"></i> Payments</a></li>
            <li><a href="#"><i class="fas fa-check-circle"></i> Status</a></li>
        </ul>
    </aside>

    <main class="main-content">
        <div class="apply-container">
            <div class="page-header">
                <h1>Hostel Application Form</h1>
                <p>Confirm your details and submit your application for the upcoming academic year.</p>
            </div>
            
            <!-- JSP Logic will show ONE of the following three scenarios -->
            
            <!-- SCENARIO 1: Main Application Form -->
            <form action="handle_application.jsp" method="POST">
                <div class="card">
                    <div class="card-header">
                        <h2>Your Details</h2>
                    </div>
                    <div class="card-body">
                        <p style="color: var(--light-text-color); margin-top: 0; margin-bottom: 2rem;">Please verify that the following details from your profile are correct before submitting.</p>
                        <div class="details-grid">
                            <!-- JSP will fetch and display these values -->
                            <div class="detail-item">
                                <div class="label">Full Name</div>
                                <div class="value">Alex Doe</div>
                            </div>
                            <div class="detail-item">
                                <div class="label">Roll Number</div>
                                <div class="value">STUDENT12345</div>
                            </div>
                             <div class="detail-item">
                                <div class="label">Email Address</div>
                                <div class="value">alex.doe@example.com</div>
                            </div>
                             <div class="detail-item">
                                <div class="label">Department</div>
                                <div class="value">Computer Science</div>
                            </div>
                        </div>
                    </div>
                    <div class="card-footer">
                        <div class="declaration">
                            <input type="checkbox" id="terms" name="terms" required onchange="document.getElementById('submitBtn').disabled = !this.checked;">
                            <label for="terms">I have read and agree to the <a href="downloads/Hostel-Rulebook.pdf" target="_blank">Hostel Rules and Regulations</a> and confirm that the details provided are correct.</label>
                        </div>
                    </div>
                </div>
                <button type="submit" id="submitBtn" class="button-submit" style="margin-top: 1.5rem;" disabled>Submit Application</button>
            </form>
            
            <!-- SCENARIO 2: Profile Incomplete -->
            <!--
            <div class="notice-box notice-profile">
                <i class="fas fa-user-edit"></i>
                <h2>Profile Incomplete</h2>
                <p>You must complete your personal and academic profile before you can apply for the hostel.</p>
                <a href="profile.jsp">Go to Profile</a>
            </div>
            -->

            <!-- SCENARIO 3: Already Applied -->
            <!--
            <div class="notice-box notice-applied">
                <i class="fas fa-check-circle"></i>
                <h2>Application Submitted</h2>
                <p>You have already submitted your application. You can track its progress on the status page.</p>
                <a href="status.jsp">Check Status</a>
            </div>
            -->

        </div>
    </main>
</body>
</html>
