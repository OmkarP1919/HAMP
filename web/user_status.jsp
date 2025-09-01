<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Application Status</title>
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

        /* --- NEW STATUS PAGE STYLES --- */
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
        
        .status-tracker {
            position: relative;
            padding-left: 2.5rem; /* Space for the timeline line and icons */
            border-left: 3px solid var(--border-color);
        }

        .status-step {
            position: relative;
            margin-bottom: 2.5rem;
        }
        
        .status-step:last-child {
            margin-bottom: 0;
        }

        .status-icon {
            position: absolute;
            left: -2.5rem;
            top: 0;
            transform: translateX(-50%);
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            background-color: var(--card-bg);
            border: 3px solid var(--border-color);
        }
        
        .status-content {
            padding-left: 1.5rem;
        }

        .status-title {
            font-size: 1.25rem;
            font-weight: 700;
            margin: 0 0 0.25rem 0;
        }

        .status-date {
            font-size: 0.9rem;
            color: var(--light-text-color);
            margin-bottom: 0.75rem;
        }
        
        .status-description {
            font-size: 1rem;
            line-height: 1.6;
        }
        
        /* Step Status Colors */
        .status-step.complete .status-icon {
            border-color: var(--success-color);
            background-color: var(--success-color);
            color: white;
        }
        
        .status-step.in-progress .status-icon {
            border-color: var(--warning-color);
            background-color: var(--warning-color);
            color: white;
        }
        
        .status-step.pending .status-icon {
            border-color: var(--border-color);
            background-color: var(--secondary-color);
            color: var(--light-text-color);
        }
        
        .status-step.rejected .status-icon {
            border-color: var(--danger-color);
            background-color: var(--danger-color);
            color: white;
        }
        
        .card {
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            margin-top: 2.5rem;
        }
        .card-header { padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border-color); }
        .card-header h2 { margin: 0; font-size: 1.2rem; font-weight: 600; }
        .card-body { padding: 1.5rem; font-size: 1rem; color: var(--light-text-color); font-style: italic; }

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
            <a href="#" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
        </div>
    </header>

    <aside class="side-panel">
        <h2>Student Menu</h2>
        <ul class="side-panel-nav">
            <li><a href="#"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
            <li><a href="#"><i class="fas fa-file-alt"></i> Apply</a></li>
            <li><a href="#"><i class="fas fa-user-circle"></i> Profile</a></li>
            <li><a href="#"><i class="fas fa-download"></i> Downloads</a></li>
            <li><a href="#"><i class="fas fa-file-invoice-dollar"></i> Payments</a></li>
            <li><a href="#" class="active"><i class="fas fa-check-circle"></i> Status</a></li>
        </ul>
    </aside>

    <main class="main-content">
        <div class="page-header">
            <h1>Your Application Journey</h1>
        </div>

        <div class="status-tracker">
            <!-- JSP will dynamically add 'complete', 'in-progress', or 'pending' classes based on logic -->

            <!-- Step 1: Application Submitted -->
            <div class="status-step complete">
                <div class="status-icon"><i class="fas fa-check"></i></div>
                <div class="status-content">
                    <h3 class="status-title">Application Submitted</h3>
                    <p class="status-date">Submitted on: <!-- JSP outputs applied_date --></p>
                    <p class="status-description">We have received your application. It will be reviewed by the hostel administration shortly.</p>
                </div>
            </div>

            <!-- Step 2: Application Review -->
            <div class="status-step in-progress">
                <div class="status-icon"><i class="fas fa-hourglass-half"></i></div>
                <div class="status-content">
                    <h3 class="status-title">Under Review</h3>
                    <p class="status-date">Status updated on: <!-- JSP outputs review_date --></p>
                    <p class="status-description">Your application is currently being reviewed by the administration. This may take a few business days.</p>
                </div>
            </div>

            <!-- Step 3: Application Approved/Rejected -->
            <!-- JSP Logic: Show this step only after review is complete -->
            <div class="status-step pending">
                <!-- Change class to 'complete' for Approved, 'rejected' for Rejected -->
                <div class="status-icon"><i class="fas fa-gavel"></i></div>
                <div class="status-content">
                    <h3 class="status-title">Application Approved</h3> <!-- Or "Application Rejected" -->
                    <p class="status-date">Awaiting decision...</p>
                    <p class="status-description">Once your application is reviewed, the decision will be displayed here. If approved, you will be prompted to pay the fees.</p>
                </div>
            </div>
            
            <!-- Step 4: Payment -->
            <div class="status-step pending">
                <div class="status-icon"><i class="fas fa-credit-card"></i></div>
                <div class="status-content">
                    <h3 class="status-title">Fee Payment</h3>
                    <p class="status-date">Pending</p>
                    <p class="status-description">After your application is approved, you can proceed to the payments page to pay the hostel fees.</p>
                </div>
            </div>

            <!-- Step 5: Room Allocated -->
            <div class="status-step pending">
                <div class="status-icon"><i class="fas fa-key"></i></div>
                <div class="status-content">
                    <h3 class="status-title">Room Allocated</h3>
                    <p class="status-date">Pending</p>
                    <p class="status-description">Your room details will be displayed on the dashboard once the payment is confirmed.</p>
                </div>
            </div>
        </div>

        <!-- Admin Remarks Card -->
        <!-- JSP Logic: Only show this card if there are remarks in the database -->
        <div class="card">
            <div class="card-header"><h2>Administrator Remarks</h2></div>
            <div class="card-body">
                <!-- JSP outputs remarks here, or a default message -->
                Your application has been provisionally approved. Please proceed with the fee payment within 7 days to confirm your allocation.
            </div>
        </div>

    </main>
</body>
</html>
