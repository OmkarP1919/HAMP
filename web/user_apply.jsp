<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>New Hostel Application</title>
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
        * { box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif; margin: 0; background-color: var(--secondary-color);
            color: var(--primary-color); height: 100vh; display: grid; grid-template-rows: auto 1fr;
            grid-template-columns: 260px 1fr; grid-template-areas: "header header" "sidebar main";
        }
        .top-panel {
            grid-area: header; background: linear-gradient(135deg, var(--accent-color), #4f87ff);
            color: #ffffff; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; z-index: 10;
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
        .main-content {
            grid-area: main; padding: 2.5rem; overflow-y: auto; display: flex; justify-content: center;
        }
        .apply-container { width: 100%; max-width: 800px; }
        .page-header h1 { font-size: 2rem; font-weight: 800; margin: 0 0 0.5rem 0; }
        .page-header p { font-size: 1.1rem; color: var(--light-text-color); margin-bottom: 2.5rem; }
        .card {
            background-color: var(--card-bg); border: 1px solid var(--border-color);
            border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); margin-bottom: 1.5rem;
        }
        .card-header { padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border-color); }
        .card-header h2 { margin: 0; font-size: 1.2rem; font-weight: 600; }
        .card-body { padding: 2rem 1.5rem; }
        .details-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.5rem; }
        .detail-item .label { font-size: 0.9rem; color: var(--light-text-color); font-weight: 500; margin-bottom: 0.25rem; }
        .detail-item .value {
            font-size: 1rem; font-weight: 600; padding: 0.75rem 1rem;
            background-color: var(--secondary-color); border-radius: 6px; border: 1px solid var(--border-color);
        }
        .selection-group input[type="radio"] { display: none; }
        .selection-group { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; }
        .selection-card {
            display: flex; align-items: center; padding: 1.5rem; border: 2px solid var(--border-color);
            border-radius: 8px; cursor: pointer; transition: all 0.2s ease-in-out; gap: 1rem;
        }
        .selection-card:hover { border-color: var(--accent-color); }
        .selection-card i { font-size: 2rem; color: var(--accent-color); }
        .selection-card .name { font-weight: 600; font-size: 1.1rem; }
        .selection-card .type { font-size: 0.9rem; color: var(--light-text-color); }
        .selection-group input[type="radio"]:checked + .selection-card {
            border-color: var(--accent-color); background-color: #eff6ff; box-shadow: 0 0 0 2px var(--accent-color);
        }
        .declaration { display: flex; align-items: flex-start; gap: 0.75rem; }
        .declaration input[type="checkbox"] { margin-top: 5px; width: 1.2em; height: 1.2em; }
        .declaration label { font-size: 1rem; line-height: 1.6; color: var(--light-text-color); }
        .declaration label a { color: var(--accent-color); font-weight: 600; text-decoration: none; }
        .button-submit {
            width: 100%; padding: 1rem; border: none; border-radius: 8px; background-color: var(--accent-color);
            color: white; font-size: 1.1rem; font-weight: 700; cursor: pointer; transition: all 0.2s ease;
        }
        .button-submit:disabled { background-color: #9ca3af; cursor: not-allowed; }
        .button-submit:hover:not(:disabled) { background-color: #1d4ed8; }
        @media (max-width: 992px) {
            body { grid-template-columns: 1fr; grid-template-rows: auto auto 1fr; grid-template-areas: "header" "sidebar" "main"; }
            .side-panel { border-right: none; border-bottom: 1px solid var(--border-color); }
        }
    </style>
</head>
<body>
    <header class="top-panel">
        <div class="logo-title"><h1>Hostel Mate</h1></div>
        <div class="user-menu"><span class="user-info"><i class="fas fa-user-circle"></i> Welcome, Alex</span><a href="#" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a></div>
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
                <h1>New Hostel Application</h1>
                <p>Please follow the steps below to apply for hostel accommodation.</p>
            </div>
            <form action="handle_application.jsp" method="POST">
                <!-- This field will be hidden but tells the server it's a new application -->
                <input type="hidden" name="application_type" value="New">

                <div class="card">
                    <div class="card-header"><h2>Step 1: Verify Your Details</h2></div>
                    <div class="card-body">
                        <div class="details-grid">
                            <div class="detail-item"><div class="label">Full Name</div><div class="value">Alex Doe</div></div>
                            <div class="detail-item"><div class="label">Roll Number</div><div class="value">STUDENT12345</div></div>
                            <div class="detail-item"><div class="label">Email Address</div><div class="value">alex.doe@example.com</div></div>
                            <div class="detail-item"><div class="label">Department</div><div class="value">Computer Science</div></div>
                        </div>
                    </div>
                </div>
                <div class="card">
                    <div class="card-header"><h2>Step 2: Select Your Hostel</h2></div>
                    <div class="card-body">
                        <div class="selection-group">
                            <input type="radio" id="hostelA" name="hostel_choice" value="A" required>
                            <label for="hostelA" class="selection-card">
                                <i class="fas fa-male"></i><div><div class="name">Hostel A</div><div class="type">Boys Hostel</div></div>
                            </label>
                            <input type="radio" id="hostelB" name="hostel_choice" value="B">
                            <label for="hostelB" class="selection-card">
                                <i class="fas fa-female"></i><div><div class="name">Hostel B</div><div class="type">Girls Hostel</div></div>
                            </label>
                             <input type="radio" id="hostelC" name="hostel_choice" value="C">
                            <label for="hostelC" class="selection-card">
                                <i class="fas fa-male"></i><div><div class="name">Hostel C</div><div class="type">Boys Hostel</div></div>
                            </label>
                        </div>
                    </div>
                </div>
                <div class="card">
                    <div class="card-header"><h2>Step 3: Declaration</h2></div>
                    <div class="card-body">
                        <div class="declaration">
                            <input type="checkbox" id="terms" name="terms" required onchange="document.getElementById('submitBtn').disabled = !this.checked;">
                            <label for="terms">I have read and agree to the <a href="downloads/Hostel-Rulebook.pdf" target="_blank">Hostel Rules and Regulations</a> and confirm that the details provided are correct.</label>
                        </div>
                    </div>
                </div>
                <button type="submit" id="submitBtn" class="button-submit" style="margin-top: 1.5rem;" disabled>Submit Application</button>
            </form>
        </div>
    </main>
</body>
</html>
