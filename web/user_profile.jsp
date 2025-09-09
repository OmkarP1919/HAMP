<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Profile</title>
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
            --success-color: #10b981;
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

        /* --- NEW PROFILE PAGE STYLES --- */
        .main-content {
            grid-area: main;
            padding: 2.5rem;
            overflow-y: auto;
        }

        .profile-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
        }

        .profile-header h1 {
            margin: 0;
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

        .card-body {
            padding: 1.5rem;
        }
        
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }
        
        .form-group label {
            font-weight: 500;
            margin-bottom: 0.5rem;
            font-size: 0.9rem;
        }

        .form-group input, .form-group select, .form-group textarea {
            padding: 0.8rem 1rem;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            font-size: 1rem;
            font-family: 'Inter', sans-serif;
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
            outline: none;
            border-color: var(--accent-color);
            box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.2);
        }
        
        /* Read-only fields for auth data */
        .form-group input[readonly] {
            background-color: var(--secondary-color);
            cursor: not-allowed;
        }
        
        .form-group textarea {
            resize: vertical;
            min-height: 100px;
        }
        
        .full-width {
            grid-column: 1 / -1;
        }

        .card-footer {
            padding: 1.25rem 1.5rem;
            border-top: 1px solid var(--border-color);
            background-color: var(--secondary-color);
            text-align: right;
            border-bottom-left-radius: 12px;
            border-bottom-right-radius: 12px;
        }
        
        .button {
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        .button-primary {
            background-color: var(--accent-color);
            color: white;
        }
        
        .button-primary:hover {
            background-color: #1d4ed8;
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
            <li><a href="user_apply.jsp"><i class="fas fa-file-alt"></i> Apply</a></li>
            <li><a href="#" class="active"><i class="fas fa-user-circle"></i> Profile</a></li>
            <li><a href="user_downloads.jsp"><i class="fas fa-download"></i> Downloads</a></li>
            <li><a href="user_payfees.jsp"><i class="fas fa-file-invoice-dollar"></i> Payments</a></li>
            <li><a href="user_status.jsp"><i class="fas fa-check-circle"></i> Status</a></li>
        </ul>
    </aside>

    <main class="main-content">
        <form action="update-profile.jsp" method="POST">
            <div class="profile-header">
                <h1>My Profile</h1>
            </div>

            <!-- Authentication Details Card -->
            <div class="card">
                <div class="card-header"><h2>Account Details</h2></div>
                <div class="card-body">
                    <div class="form-grid">
                        <!-- Fields from student_auth table -->
                        <div class="form-group">
                            <label for="fullname">Full Name</label>
                            <input type="text" id="fullname" name="fullname" value="Alex Doe" readonly>
                        </div>
                        <div class="form-group">
                            <label for="roll_no">Roll Number</label>
                            <input type="text" id="roll_no" name="roll_no" value="STUDENT12345" readonly>
                        </div>
                        <div class="form-group">
                            <label for="email">Email Address</label>
                            <input type="email" id="email" name="email" value="alex.doe@example.com" readonly>
                        </div>
                        <div class="form-group">
                            <label for="mobile">Mobile Number</label>
                            <input type="tel" id="mobile" name="mobile" value="9876543210" readonly>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Profile Details Card -->
            <div class="card">
                <div class="card-header"><h2>Personal & Academic Information</h2></div>
                <div class="card-body">
                    <div class="form-grid">
                        <!-- Fields from student_profiles table -->
                        <div class="form-group">
                            <label for="gender">Gender</label>
                            <select id="gender" name="gender" required>
                                <option value="" disabled selected>Select Gender</option>
                                <option value="Male">Male</option>
                                <option value="Female">Female</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="dob">Date of Birth</label>
                            <input type="date" id="dob" name="dob" required>
                        </div>
                        <div class="form-group">
                            <label for="aadhar_no">Aadhar Number</label>
                            <input type="text" id="aadhar_no" name="aadhar_no" pattern="\d{12}" title="12-digit Aadhar number" required>
                        </div>
                        <div class="form-group">
                            <label for="parents_mobile">Parent's Mobile Number</label>
                            <input type="tel" id="parents_mobile" name="parents_mobile" pattern="\d{10}" title="10-digit mobile number" required>
                        </div>
                        <div class="form-group">
                            <label for="course">Course</label>
                            <input type="text" id="course" name="course" placeholder="e.g., Bachelor of Engineering" required>
                        </div>
                        <div class="form-group">
                            <label for="department">Department</label>
                            <input type="text" id="department" name="department" placeholder="e.g., Computer Science" required>
                        </div>
                        <div class="form-group">
                            <label for="year">Year of Study</label>
                            <select id="year" name="year" required>
                                <option value="" disabled selected>Select Year</option>
                                <option value="1">First Year</option>
                                <option value="2">Second Year</option>
                                <option value="3">Third Year</option>
                                <option value="4">Fourth Year</option>
                            </select>
                        </div>
                        <div class="form-group full-width">
                            <label for="address">Full Address</label>
                            <textarea id="address" name="address" placeholder="Enter your complete permanent address" required></textarea>
                        </div>
                    </div>
                </div>
                <div class="card-footer">
                    <button type="submit" class="button button-primary">Save Changes</button>
                </div>
            </div>
        </form>
    </main>
</body>
</html>
