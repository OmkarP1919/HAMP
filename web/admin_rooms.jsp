<%@ page import="java.sql.*, java.util.ArrayList, java.util.HashMap, java.util.List, java.util.Map, java.util.Collections, java.util.Comparator" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%-- =================================================================
     SERVER-SIDE LOGIC FOR ROOM MANAGEMENT (NO JS FOR FILTERING)
     ================================================================= --%>
<%
    // --- 1. SESSION SECURITY CHECK ---
    if (session.getAttribute("admin_id") == null) {
        response.sendRedirect("admin_login.jsp?error=Please login first");
        return;
    }

    String adminName = (String) session.getAttribute("admin_name"); // Assuming admin_name is set in session

    // --- 2. GATHER DYNAMIC DATA ---
    List<Map<String, Object>> rooms = new ArrayList<>();
    int totalRoomsCount = 0;
    int occupiedSlotsCount = 0;
    int totalSlotsCapacity = 0;

    List<String> uniqueFloors = new ArrayList<>(); // To populate the floor filter dropdown

    // --- 3. READ FILTER PARAMETERS FROM REQUEST ---
    String floorFilter = request.getParameter("floorFilter");
    String statusFilterAvailable = request.getParameter("statusFilterAvailable");
    String statusFilterOccupied = request.getParameter("statusFilterOccupied");
    String searchTerm = request.getParameter("searchTerm");

    // Set defaults if parameters are not present (initial load or no filter applied)
    if (floorFilter == null) floorFilter = "All";
    if (statusFilterAvailable == null) statusFilterAvailable = "on"; // Default to checked
    if (statusFilterOccupied == null) statusFilterOccupied = "on";   // Default to checked
    if (searchTerm == null) searchTerm = "";

    // --- 4. DATABASE CONNECTION & QUERIES ---
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    System.out.println("--- admin_rooms.jsp: Starting server-side processing ---");

    try {
        String url = "jdbc:mysql://localhost:3306/hamp"; // Adjust to your DB URL
        String dbUsername = "root"; // Adjust to your DB username
        String dbPassword = "root"; // Adjust to your DB password
        String driver = "com.mysql.jdbc.Driver"; // Corrected driver name for modern MySQL
        Class.forName(driver);
        conn = DriverManager.getConnection(url, dbUsername, dbPassword);
        System.out.println("DB Connection successful.");

        // Build the SQL query dynamically based on filters
        StringBuilder sqlBuilder = new StringBuilder("SELECT room_no, floor_no, total_slots, occupied_slots FROM room WHERE hostel_id = 'H1'");
        List<Object> params = new ArrayList<>();

        if (!"All".equals(floorFilter)) {
            sqlBuilder.append(" AND floor_no = ?");
            params.add(Integer.parseInt(floorFilter));
        }

        // Handle status filters
        boolean filterByAvailable = "on".equals(statusFilterAvailable);
        boolean filterByOccupied = "on".equals(statusFilterOccupied);

        if (filterByAvailable && !filterByOccupied) { // Only available
            sqlBuilder.append(" AND occupied_slots = 0");
        } else if (!filterByAvailable && filterByOccupied) { // Only occupied
            sqlBuilder.append(" AND occupied_slots > 0");
        } else if (!filterByAvailable && !filterByOccupied) { // Neither selected
             sqlBuilder.append(" AND 1 = 0"); // A condition that is always false
        }
        // If both are checked (default), no additional WHERE clause for status needed

        if (!searchTerm.isEmpty()) {
            sqlBuilder.append(" AND room_no LIKE ?");
            params.add("%" + searchTerm + "%");
        }

        sqlBuilder.append(" ORDER BY floor_no, room_no");

        pstmt = conn.prepareStatement(sqlBuilder.toString());
        System.out.println("Executing query: " + sqlBuilder.toString());

        // Set parameters
        for (int i = 0; i < params.size(); i++) {
            pstmt.setObject(i + 1, params.get(i));
        }

        rs = pstmt.executeQuery();

        int roomsFetched = 0;
        while (rs.next()) {
            roomsFetched++;
            Map<String, Object> room = new HashMap<>();

            String roomNumber = rs.getString("room_no");
            if (roomNumber == null || roomNumber.trim().isEmpty()) { // Also check for empty string
                roomNumber = "N/A";
                System.err.println("WARNING: room_no is NULL or empty for a room. Defaulting to 'N/A'.");
            }

            String floor = String.valueOf(rs.getInt("floor_no"));
            int totalSlots = rs.getInt("total_slots");
            int occupiedSlots = rs.getInt("occupied_slots");

            String roomType = "Triple"; // Still setting it for consistency, though not displayed on card

            String cssClass = "";
            String displayStatusText = "";

            if (occupiedSlots == 0) {
                cssClass = "available";
                displayStatusText = "Available";
            } else {
                cssClass = "occupied";
                if (occupiedSlots == totalSlots) {
                    displayStatusText = "Fully Occupied";
                } else {
                    displayStatusText = "Partially Occupied";
                }
            }

            room.put("room_number", roomNumber);
            room.put("floor", floor);
            room.put("room_type", roomType);
            room.put("total_slots", totalSlots);
            room.put("occupied_slots", occupiedSlots);
            room.put("status", displayStatusText);
            room.put("css_class", cssClass);

            rooms.add(room);
        }
        System.out.println("Total rooms fetched from DB matching filters: " + roomsFetched);

        // --- Fetch ALL unique floors for the dropdown (separate query) ---
        Statement stmtForFloors = null;
        ResultSet rsForFloors = null;
        try {
            stmtForFloors = conn.createStatement();
            rsForFloors = stmtForFloors.executeQuery("SELECT DISTINCT floor_no FROM room WHERE hostel_id = 'H1' ORDER BY floor_no");
            while (rsForFloors.next()) {
                uniqueFloors.add(String.valueOf(rsForFloors.getInt("floor_no")));
            }
        } finally {
            if (rsForFloors != null) try { rsForFloors.close(); } catch (SQLException ignore) {}
            if (stmtForFloors != null) try { stmtForFloors.close(); } catch (SQLException ignore) {}
        }


        // Aggregate counts from the *filtered* rooms for display
        totalRoomsCount = rooms.size();
        for(Map<String, Object> r : rooms) {
            occupiedSlotsCount += (int) r.get("occupied_slots");
            totalSlotsCapacity += (int) r.get("total_slots");
        }


    } catch (SQLException e) {
        System.err.println("SQL Error loading rooms: " + e.getMessage());
        e.printStackTrace();
        request.setAttribute("errorMessage", "Database error: " + e.getMessage());
    } catch (ClassNotFoundException e) {
        System.err.println("JDBC Driver not found: " + e.getMessage());
        e.printStackTrace();
        request.setAttribute("errorMessage", "JDBC Driver error: " + e.getMessage());
    } catch (Exception e) {
        System.err.println("General Error loading rooms: " + e.getMessage());
        e.printStackTrace();
        request.setAttribute("errorMessage", "Error loading rooms: " + e.getMessage());
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) { e.printStackTrace(); }
        try { if (pstmt != null) pstmt.close(); } catch (Exception e) { e.printStackTrace(); }
        try { if (conn != null) conn.close(); } catch (Exception e) { e.printStackTrace(); }
        System.out.println("DB Resources closed.");
    }
    System.out.println("--- admin_rooms.jsp: Finished server-side processing ---");

    double occupancyPercentage = 0.0;
    if (totalSlotsCapacity > 0) {
        occupancyPercentage = (double) occupiedSlotsCount / totalSlotsCapacity * 100;
    }
    String formattedOccupancy = String.format("%.1f", occupancyPercentage);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Room Management</title>
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
            --success-color: #10b981; /* Green for Available */
            --occupied-color: #3b82f6; /* Blue for Occupied */
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
            grid-area: header; background: linear-gradient(135deg, var(--accent-color), #4f87ff); color: #ffffff;
            padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; z-index: 10;
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
            display: flex; align-items: center; gap: 1rem; padding: 0.8rem 1rem; margin-bottom: 0.5rem;
            text-decoration: none; color: var(--light-text-color); font-weight: 500; border-radius: 6px; transition: all 0.3s ease;
        }
        .side-panel-nav li a:hover { background-color: var(--secondary-color); color: var(--primary-color); }
        .side-panel-nav li a.active { background-color: var(--accent-color); color: white; font-weight: 600; }
        .side-panel-nav li a i { width: 20px; text-align: center; }

        /* --- ROOM MANAGEMENT PAGE STYLES --- */
        .main-content {
            grid-area: main;
            padding: 2.5rem;
            overflow-y: auto;
            display: flex;
            gap: 2rem;
        }

        .filter-sidebar {
            width: 280px;
            flex-shrink: 0;
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }

        .filter-card {
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 12px;
        }
        .filter-header {
            padding: 1rem 1.25rem;
            border-bottom: 1px solid var(--border-color);
        }
        .filter-header h3 { margin: 0; font-size: 1.1rem; }
        .filter-body { padding: 1.25rem; }
        .form-group { margin-bottom: 1rem; }
        .form-group label { display: block; font-weight: 500; margin-bottom: 0.5rem; font-size: 0.9rem;}
        .form-group select { width: 100%; padding: 0.5rem; border-radius: 6px; border: 1px solid var(--border-color); }

        .checkbox-group { display: flex; align-items: center; gap: 0.75rem; }
        .checkbox-group input[type="checkbox"] { flex-shrink: 0; margin: 0; }
        .checkbox-group:not(:last-child) { margin-bottom: 0.75rem; }

        .legend-list { list-style: none; padding: 0; margin: 0; }
        .legend-item { display: flex; align-items: center; gap: 0.75rem; margin-bottom: 0.5rem; }
        .legend-item .color-box { width: 16px; height: 16px; border-radius: 4px; }
        .quick-actions .action-button {
            width: 100%; display: block; text-align: center;
            padding: 0.8rem; border-radius: 8px; font-weight: 600; text-decoration: none;
            margin-bottom: 0.75rem; transition: background-color 0.2s ease;
        }
        .btn-primary { background-color: var(--accent-color); color: white; }
        .btn-secondary { background-color: var(--primary-color); color: white; }

        .room-display {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            min-height: 0;
        }
        .overview-header {
            display: flex; justify-content: space-between; align-items: center;
            padding-bottom: 1.5rem;
            flex-shrink: 0;
        }
        .overview-header h1 { margin: 0; font-size: 2rem; }
        .search-bar input { padding: 0.5rem 1rem; border-radius: 8px; border: 1px solid var(--border-color); width: 350px; }

        /* --- IMPROVED ROOM GRID STYLES --- */
        .room-grid {
            display: grid;
            /* Allow larger cards, fewer columns for better readability */
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            gap: 1.25rem; /* Increased gap for more breathing room */
            padding: 0;
        }

        .room-card {
            color: white;
            border-radius: 12px; /* Slightly more rounded corners */
            padding: 1.25rem; /* Increased padding */
            text-align: center;
            border: 2px solid transparent;
            /* Using aspect-ratio for consistent card shape, adjust as needed */
            aspect-ratio: 1 / 1;
            display: flex;
            flex-direction: column;
            justify-content: space-between; /* Distribute content */
            align-items: center;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1); /* More pronounced shadow */
            transition: transform 0.2s ease, box-shadow 0.2s ease; /* Add transition for hover effect */
        }
        .room-card:hover { /* Simple hover effect for interactivity */
            transform: translateY(-5px);
            box-shadow: 0 6px 15px rgba(0,0,0,0.15);
        }

        .room-card .room-number {
            font-size: 1.8rem; /* Larger room number */
            font-weight: 800;
            margin-bottom: 0.5rem; /* Space between number and occupancy */
            flex-grow: 1; /* Allows room number to take available space */
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .room-card .room-occupancy {
            font-size: 1rem; /* Larger occupancy text */
            opacity: 0.95;
            font-weight: 500;
            background-color: rgba(0,0,0,0.15); /* Slightly darker background for better contrast */
            padding: 0.4rem 0.8rem;
            border-radius: 6px;
        }


        .room-card.available { background-color: var(--success-color); border-color: #059669; }
        .room-card.occupied { background-color: var(--occupied-color); border-color: #1d4ed8; }

        /* Responsive */
        @media (max-width: 1200px) {
            .main-content { flex-direction: column; gap: 1.5rem;}
            .filter-sidebar { width: 100%; }
            body { grid-template-columns: 1fr; grid-template-rows: auto auto 1fr; grid-template-areas: "header" "sidebar" "main"; }
            .side-panel { border-right: none; border-bottom: 1px solid var(--border-color); }
        }
        @media (max-width: 768px) {
            .overview-header { flex-direction: column; align-items: flex-start; gap: 1rem; }
            .search-bar input { width: 100%; }
            /* Adjust grid for smaller screens to still have decent sized cards */
            .room-grid { grid-template-columns: repeat(auto-fill, minmax(100px, 1fr)); gap: 1rem; }
            .room-card .room-number { font-size: 1.5rem; }
            .room-card .room-occupancy { font-size: 0.85rem; padding: 0.3rem 0.6rem; }
        }
    </style>
</head>
<body>
    <header class="top-panel">
        <div class="logo-title"><h1>Hostel Mate</h1></div>
        <div class="user-menu">
            <span class="user-info"><i class="fas fa-user-circle"></i> Welcome, <%= adminName != null ? adminName : "Admin" %></span>
            <a href="admin_login.jsp" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
        </div>
    </header>
    <aside class="side-panel">
        <h2>Admin Menu</h2>
        <ul class="side-panel-nav">
            <li><a href="admin_dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
            <li><a href="admin_profile.jsp"><i class="fas fa-user-cog"></i> Profile</a></li>
            <li><a href="admin_applications.jsp"><i class="fas fa-file-signature"></i> Applications</a></li>
            <li><a href="admin_slist.jsp"><i class="fas fa-users"></i> Students</a></li>
            <li><a href="admin_rooms.jsp" class="active"><i class="fas fa-bed"></i> Rooms</a></li>
        </ul>
    </aside>
    <main class="main-content">
        <div class="filter-sidebar">
            <div class="filter-card">
                <div class="filter-header"><h3>Filters & Options</h3></div>
                <div class="filter-body">
                    <%-- The form for filters will submit back to this JSP --%>
                    <form action="admin_rooms.jsp" method="get" id="filterForm">
                        <div class="form-group">
                            <label for="floorFilter">Floor</label>
                            <select id="floorFilter" name="floorFilter" onchange="document.getElementById('filterForm').submit()">
                                <option value="All" <%= "All".equals(floorFilter) ? "selected" : "" %>>All Floors</option>
                                <% for (String floor : uniqueFloors) { %>
                                    <option value="<%= floor %>" <%= floor.equals(floorFilter) ? "selected" : "" %>><%= floor %> Floor</option>
                                <% } %>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Status</label>
                            <div class="checkbox-group">
                                <input type="checkbox" id="statusFilterOccupied" name="statusFilterOccupied" <%= "on".equals(statusFilterOccupied) ? "checked" : "" %> onchange="document.getElementById('filterForm').submit()">
                                <label for="statusFilterOccupied">Occupied</label>
                            </div>
                            <div class="checkbox-group">
                                <input type="checkbox" id="statusFilterAvailable" name="statusFilterAvailable" <%= "on".equals(statusFilterAvailable) ? "checked" : "" %> onchange="document.getElementById('filterForm').submit()">
                                <label for="statusFilterAvailable">Available</label>
                            </div>
                        </div>
                        <%-- Add a hidden input for search term to persist it across submits --%>
                        <input type="hidden" id="hiddenSearchTerm" name="searchTerm" value="<%= searchTerm %>">
                    </form>
                </div>
            </div>
            <div class="filter-card">
                <div class="filter-header"><h3>Legend</h3></div>
                <div class="filter-body">
                    <ul class="legend-list">
                        <li class="legend-item"><div class="color-box" style="background-color: var(--occupied-color);"></div> Occupied</li>
                        <li class="legend-item"><div class="color-box" style="background-color: var(--success-color);"></div> Available</li>
                    </ul>
                </div>
            </div>
            <div class="filter-card quick-actions">
                <div class="filter-header"><h3>Quick Actions</h3></div>
                <div class="filter-body">
                    <a href="#" class="action-button btn-primary"><i class="fas fa-plus"></i> Add New Room</a>
                    <a href="#" class="action-button btn-secondary"><i class="fas fa-file-export"></i> Export Report</a>
                </div>
            </div>
        </div>
        <div class="room-display">
            <div class="overview-header">
                <div>
                    <h1>Room Overview</h1>
                    <p style="margin:0; color: var(--light-text-color);">Total: <%= totalRoomsCount %> rooms | Occupancy: <%= formattedOccupancy %>%</p>
                </div>
                <div class="search-bar">
                    <%-- This input will update a hidden field and submit the form --%>
                    <input type="text" id="searchRoom" placeholder="Search room number..." value="<%= searchTerm %>"
                           onkeyup="document.getElementById('hiddenSearchTerm').value = this.value; document.getElementById('filterForm').submit();">
                </div>
            </div>
            <div id="roomContainer" class="room-grid">
                <%-- Rooms will be directly rendered here by JSP --%>
                <% if (rooms.isEmpty()) { %>
                    <p id="noRoomsMessage" style="text-align: center; margin-top: 2rem; color: var(--light-text-color); grid-column: 1 / -1;">No rooms found in the database for Hostel H1 or matching your criteria.</p>
                <% } else { %>
                    <%
                        // The 'rooms' list is already filtered and sorted by the server-side logic
                        for (Map<String, Object> room : rooms) {
                            String roomNumber = (String) room.get("room_number");
                            String cssClass = (String) room.get("css_class");
                            int totalSlots = (int) room.get("total_slots");
                            int occupiedSlots = (int) room.get("occupied_slots");
                    %>
                        <div class="room-card <%= cssClass %>">
                            <div class="room-number"><%= roomNumber %></div>
                            <div class="room-occupancy"><%= occupiedSlots %>/<%= totalSlots %> Seats</div>
                        </div>
                    <%
                        }
                    %>
                <% } %>
            </div>
        </div>
    </main>

    <script>
        // Optional: A small piece of JS to prevent form submission on Enter key in search bar
        // if you want onkeyup to be the primary trigger.
        document.getElementById('searchRoom').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault(); // Prevent default form submission
                document.getElementById('hiddenSearchTerm').value = this.value;
                document.getElementById('filterForm').submit();
            }
        });
    </script>
</body>
</html>