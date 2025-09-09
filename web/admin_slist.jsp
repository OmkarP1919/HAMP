<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Management</title>
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

        /* --- STUDENT LIST PAGE STYLES --- */
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
        }

        .filter-bar {
            padding: 1.5rem;
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
            align-items: center;
            border-bottom: 1px solid var(--border-color);
        }
        
        .search-group {
            flex-grow: 1;
            position: relative;
        }

        .search-group i {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--light-text-color);
        }

        .search-group input, .filter-group select {
            padding: 0.75rem;
            border-radius: 8px;
            border: 1px solid var(--border-color);
            font-size: 1rem;
            font-family: 'Inter', sans-serif;
        }

        .search-group input {
            padding-left: 2.75rem;
            width: 100%;
        }

        .filter-group select {
            min-width: 150px;
        }

        .button-filter {
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

        .table-container {
            width: 100%;
            overflow-x: auto;
        }

        .student-table {
            width: 100%;
            border-collapse: collapse;
        }

        .student-table th, .student-table td {
            padding: 1.25rem 1.5rem;
            text-align: left;
            border-bottom: 1px solid var(--border-color);
            white-space: nowrap;
        }
        
        .student-table thead {
             background-color: var(--secondary-color);
        }

        .student-table th {
            font-size: 0.85rem;
            font-weight: 600;
            text-transform: uppercase;
            color: var(--light-text-color);
        }
        
        .student-table tbody tr:hover {
            background-color: var(--secondary-color);
        }
        
        .button-action {
            padding: 0.5rem 1rem;
            border-radius: 6px;
            font-weight: 500;
            text-decoration: none;
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            color: var(--primary-color);
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .button-action:hover {
            background-color: var(--secondary-color);
            border-color: #d1d5db;
        }
        
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
            <li><a href="admin_profile.jsp"><i class="fas fa-user-cog"></i> Profile</a></li>
            <li><a href="admin_applications.jsp" class="active"><i class="fas fa-file-signature"></i> Applications</a></li>
            <li><a href="#"><i class="fas fa-users"></i> Students</a></li>
            <li><a href="admin_rooms.jsp"><i class="fas fa-bed"></i> Rooms</a></li>
        </ul>
    </aside>
    <main class="main-content">
        <div class="page-header">
            <h1>Student Management</h1>
        </div>

        <div class="card">
            <div class="filter-bar">
                <div class="search-group">
                    <i class="fas fa-search"></i>
                    <input type="text" placeholder="Search by name or roll no...">
                </div>
                <div class="filter-group">
                    <select>
                        <option value="">All Hostels</option>
                        <option value="A">Hostel A</option>
                        <option value="B">Hostel B</option>
                    </select>
                </div>
                <div class="filter-group">
                    <select>
                        <option value="">All Courses</option>
                        <option value="CS">Computer Science</option>
                        <option value="ME">Mechanical Engg.</option>
                    </select>
                </div>
                 <div class="filter-group">
                    <select>
                        <option value="">All Years</option>
                        <option value="1">First Year</option>
                        <option value="2">Second Year</option>
                    </select>
                </div>
                <button class="button-filter">Filter</button>
            </div>
            <div class="table-container">
                <table class="student-table">
                    <thead>
                        <tr>
                            <th>Roll No</th>
                            <th>Full Name</th>
                            <th>Course & Year</th>
                            <th>Hostel</th>
                            <th>Room No</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- JSP will generate these rows dynamically -->
                        <tr>
                            <td>STUDENT12345</td>
                            <td>Alex Doe</td>
                            <td>Computer Science, Year 2</td>
                            <td>Hostel A</td>
                            <td>A-101</td>
                            <td><a href="#" class="button-action">View Details</a></td>
                        </tr>
                        <tr>
                            <td>STUDENT12346</td>
                            <td>Sarah Smith</td>
                            <td>Mechanical Engg., Year 3</td>
                            <td>Hostel B</td>
                            <td>B-204</td>
                            <td><a href="#" class="button-action">View Details</a></td>
                        </tr>
                        <tr>
                            <td>STUDENT12347</td>
                            <td>Mike Johnson</td>
                            <td>Computer Science, Year 2</td>
                            <td>Hostel A</td>
                            <td>A-102</td>
                            <td><a href="#" class="button-action">View Details</a></td>
                        </tr>
                         <!-- Add more sample rows as needed -->
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</body>
</html>
