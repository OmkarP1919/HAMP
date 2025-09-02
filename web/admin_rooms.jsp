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
            --maintenance-color: #f59e0b; /* Yellow for Maintenance */
            --danger-color: #ef4444; /* Red for Out of Order */
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

        .room-grid {
            flex-grow: 1;
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(90px, 1fr));
            gap: 0.5rem 0.75rem; /* FIX: Reduced vertical gap */
            overflow-y: auto;
            padding: 1rem 0.5rem;
        }

        .room-card {
            color: white;
            border-radius: 8px;
            padding: 0.75rem;
            text-align: center;
            border: 2px solid transparent;
            aspect-ratio: 1 / 1;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        .room-card .room-number { font-size: 1.2rem; font-weight: 800; }
        .room-card .room-type { font-size: 0.8rem; opacity: 0.9; }

        .room-card.available { background-color: var(--success-color); border-color: #059669; }
        .room-card.occupied { background-color: var(--occupied-color); border-color: #1d4ed8; }
        .room-card.maintenance { background-color: var(--maintenance-color); border-color: #b45309; }
        .room-card.out-of-order { background-color: var(--danger-color); border-color: #b91c1c; }
        
        /* Responsive */
        @media (max-width: 1200px) {
            .filter-sidebar { display: none; }
        }
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
            <a href="#" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
        </div>
    </header>
    <aside class="side-panel">
        <h2>Admin Menu</h2>
        <ul class="side-panel-nav">
            <li><a href="#"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
            <li><a href="#"><i class="fas fa-user-cog"></i> Profile</a></li>
            <li><a href="#"><i class="fas fa-file-signature"></i> Applications</a></li>
            <li><a href="#"><i class="fas fa-users"></i> Students</a></li>
            <li><a href="#" class="active"><i class="fas fa-bed"></i> Rooms</a></li>
        </ul>
    </aside>
    <main class="main-content">
        <div class="filter-sidebar">
            <div class="filter-card">
                <div class="filter-header"><h3>Filters & Options</h3></div>
                <div class="filter-body">
                    <div class="form-group">
                        <label for="floor">Floor</label>
                        <select id="floor"><option>All Floors</option><option>1st Floor</option><option>2nd Floor</option><option>3rd Floor</option></select>
                    </div>
                    <div class="form-group">
                        <label for="room_type">Room Type</label>
                        <select id="room_type"><option>All Types</option><option>Single</option><option>Double</option><option>Triple</option></select>
                    </div>
                    <div class="form-group">
                        <label>Status</label>
                        <div class="checkbox-group"><input type="checkbox" id="status_occupied" checked> <label for="status_occupied">Occupied</label></div>
                        <div class="checkbox-group"><input type="checkbox" id="status_available" checked> <label for="status_available">Available</label></div>
                        <div class="checkbox-group"><input type="checkbox" id="status_maintenance" checked> <label for="status_maintenance">Maintenance</label></div>
                        <div class="checkbox-group"><input type="checkbox" id="status_out_of_order" checked> <label for="status_out_of_order">Out of Order</label></div>
                    </div>
                </div>
            </div>
            <div class="filter-card">
                <div class="filter-header"><h3>Legend</h3></div>
                <div class="filter-body">
                    <ul class="legend-list">
                        <li class="legend-item"><div class="color-box" style="background-color: var(--occupied-color);"></div> Occupied</li>
                        <li class="legend-item"><div class="color-box" style="background-color: var(--success-color);"></div> Available</li>
                        <li class="legend-item"><div class="color-box" style="background-color: var(--maintenance-color);"></div> Maintenance</li>
                        <li class="legend-item"><div class="color-box" style="background-color: var(--danger-color);"></div> Out of Order</li>
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
                    <p style="margin:0; color: var(--light-text-color);">Total: 250 rooms | Occupancy: 68.9%</p>
                </div>
                <div class="search-bar">
                    <input type="text" placeholder="Search room...">
                </div>
            </div>
            <div class="room-grid">
                <!-- JSP will generate these room cards dynamically -->
                <div class="room-card occupied"><div class="room-number">101</div><div class="room-type">Single</div></div>
                <div class="room-card available"><div class="room-number">102</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">103</div><div class="room-type">Single</div></div>
                <div class="room-card maintenance"><div class="room-number">104</div><div class="room-type">Triple</div></div>
                <div class="room-card occupied"><div class="room-number">105</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">106</div><div class="room-type">Quad</div></div>
                <div class="room-card out-of-order"><div class="room-number">107</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">108</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">109</div><div class="room-type">Triple</div></div>
                <div class="room-card occupied"><div class="room-number">110</div><div class="room-type">Triple</div></div>
                <div class="room-card available"><div class="room-number">111</div><div class="room-type">Double</div></div>
                <div class="room-card available"><div class="room-number">112</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">113</div><div class="room-type">Double</div></div>
                <div class="room-card available"><div class="room-number">114</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">115</div><div class="room-type">Triple</div></div>
                <div class="room-card available"><div class="room-number">116</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">117</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">118</div><div class="room-type">Quad</div></div>
                <div class="room-card maintenance"><div class="room-number">119</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">120</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">121</div><div class="room-type">Single</div></div>
                <div class="room-card available"><div class="room-number">122</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">123</div><div class="room-type">Single</div></div>
                <div class="room-card maintenance"><div class="room-number">124</div><div class="room-type">Triple</div></div>
                <div class="room-card occupied"><div class="room-number">125</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">126</div><div class="room-type">Quad</div></div>
                <div class="room-card out-of-order"><div class="room-number">127</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">128</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">129</div><div class="room-type">Triple</div></div>
                <div class="room-card occupied"><div class="room-number">130</div><div class="room-type">Triple</div></div>
                <div class="room-card available"><div class="room-number">131</div><div class="room-type">Double</div></div>
                <div class="room-card available"><div class="room-number">132</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">133</div><div class="room-type">Double</div></div>
                <div class="room-card available"><div class="room-number">134</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">135</div><div class="room-type">Triple</div></div>
                <div class="room-card available"><div class="room-number">136</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">137</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">138</div><div class="room-type">Quad</div></div>
                <div class="room-card maintenance"><div class="room-number">139</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">140</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">141</div><div class="room-type">Single</div></div>
                <div class="room-card available"><div class="room-number">142</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">143</div><div class="room-type">Single</div></div>
                <div class="room-card maintenance"><div class="room-number">144</div><div class="room-type">Triple</div></div>
                <div class="room-card occupied"><div class="room-number">145</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">146</div><div class="room-type">Quad</div></div>
                <div class="room-card out-of-order"><div class="room-number">147</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">148</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">149</div><div class="room-type">Triple</div></div>
                <div class="room-card occupied"><div class="room-number">150</div><div class="room-type">Triple</div></div>
                <div class="room-card available"><div class="room-number">201</div><div class="room-type">Double</div></div>
                <div class="room-card available"><div class="room-number">202</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">203</div><div class="room-type">Triple</div></div>
                <div class="room-card available"><div class="room-number">204</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">205</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">206</div><div class="room-type">Quad</div></div>
                <div class="room-card out-of-order"><div class="room-number">207</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">208</div><div class="room-type">Double</div></div>
                <div class="room-card available"><div class="room-number">209</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">210</div><div class="room-type">Triple</div></div>
                <div class="room-card available"><div class="room-number">211</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">212</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">213</div><div class="room-type">Quad</div></div>
                <div class="room-card maintenance"><div class="room-number">214</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">215</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">216</div><div class="room-type">Single</div></div>
                <div class="room-card available"><div class="room-number">217</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">218</div><div class="room-type">Single</div></div>
                <div class="room-card maintenance"><div class="room-number">219</div><div class="room-type">Triple</div></div>
                <div class="room-card occupied"><div class="room-number">220</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">221</div><div class="room-type">Quad</div></div>
                <div class="room-card out-of-order"><div class="room-number">222</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">223</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">224</div><div class="room-type">Triple</div></div>
                <div class="room-card occupied"><div class="room-number">225</div><div class="room-type">Triple</div></div>
                <div class="room-card available"><div class="room-number">226</div><div class="room-type">Double</div></div>
                <div class="room-card available"><div class="room-number">227</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">228</div><div class="room-type">Double</div></div>
                <div class="room-card available"><div class="room-number">229</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">230</div><div class="room-type">Triple</div></div>
                <div class="room-card available"><div class="room-number">231</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">232</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">233</div><div class="room-type">Quad</div></div>
                <div class="room-card maintenance"><div class="room-number">234</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">235</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">236</div><div class="room-type">Single</div></div>
                <div class="room-card available"><div class="room-number">237</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">238</div><div class="room-type">Single</div></div>
                <div class="room-card maintenance"><div class="room-number">239</div><div class="room-type">Triple</div></div>
                <div class="room-card occupied"><div class="room-number">240</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">241</div><div class="room-type">Quad</div></div>
                <div class="room-card out-of-order"><div class="room-number">242</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">243</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">244</div><div class="room-type">Triple</div></div>
                <div class="room-card occupied"><div class="room-number">245</div><div class="room-type">Triple</div></div>
                <div class="room-card available"><div class="room-number">246</div><div class="room-type">Double</div></div>
                <div class="room-card available"><div class="room-number">247</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">248</div><div class="room-type">Double</div></div>
                <div class="room-card available"><div class="room-number">249</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">250</div><div class="room-type">Triple</div></div>
                <div class="room-card available"><div class="room-number">301</div><div class="room-type">Double</div></div>
                <div class="room-card available"><div class="room-number">302</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">303</div><div class="room-type">Triple</div></div>
                <div class="room-card available"><div class="room-number">304</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">305</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">306</div><div class="room-type">Quad</div></div>
                <div class="room-card out-of-order"><div class="room-number">307</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">308</div><div class="room-type">Double</div></div>
                <div class="room-card available"><div class="room-number">309</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">310</div><div class="room-type">Triple</div></div>
                <div class="room-card available"><div class="room-number">311</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">312</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">313</div><div class="room-type">Quad</div></div>
                <div class="room-card maintenance"><div class="room-number">314</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">315</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">316</div><div class="room-type">Single</div></div>
                <div class="room-card available"><div class="room-number">317</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">318</div><div class="room-type">Single</div></div>
                <div class="room-card maintenance"><div class="room-number">319</div><div class="room-type">Triple</div></div>
                <div class="room-card occupied"><div class="room-number">320</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">321</div><div class="room-type">Quad</div></div>
                <div class="room-card out-of-order"><div class="room-number">322</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">323</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">324</div><div class="room-type">Triple</div></div>
                <div class="room-card occupied"><div class="room-number">325</div><div class="room-type">Triple</div></div>
                <div class="room-card available"><div class="room-number">326</div><div class="room-type">Double</div></div>
                <div class="room-card available"><div class="room-number">327</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">328</div><div class="room-type">Double</div></div>
                <div class="room-card available"><div class="room-number">329</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">330</div><div class="room-type">Triple</div></div>
                <div class="room-card available"><div class="room-number">331</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">332</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">333</div><div class="room-type">Quad</div></div>
                <div class="room-card maintenance"><div class="room-number">334</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">335</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">336</div><div class="room-type">Single</div></div>
                <div class="room-card available"><div class="room-number">337</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">338</div><div class="room-type">Single</div></div>
                <div class="room-card maintenance"><div class="room-number">339</div><div class="room-type">Triple</div></div>
                <div class="room-card occupied"><div class="room-number">340</div><div class="room-type">Double</div></div>
                <div class="room-card occupied"><div class="room-number">341</div><div class="room-type">Quad</div></div>
                <div class="room-card out-of-order"><div class="room-number">342</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">343</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">344</div><div class="room-type">Triple</div></div>
                <div class="room-card occupied"><div class="room-number">345</div><div class="room-type">Triple</div></div>
                <div class="room-card available"><div class="room-number">346</div><div class="room-type">Double</div></div>
                <div class="room-card available"><div class="room-number">347</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">348</div><div class="room-type">Double</div></div>
                <div class="room-card available"><div class="room-number">349</div><div class="room-type">Single</div></div>
                <div class="room-card occupied"><div class="room-number">350</div><div class="room-type">Triple</div></div>
            </div>
        </div>
    </main>
</body>
</html>

