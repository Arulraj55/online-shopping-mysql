import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Grid,
  Card,
  CardContent,
  Button,
  Alert,
  CircularProgress,
  Chip,
} from '@mui/material';
import {
  TrendingUp,
  Inventory,
  ShoppingCart,
  People,
} from '@mui/icons-material';
import { healthAPI, productAPI, apiCall } from '../services/api';

const Home = () => {
  const [healthStatus, setHealthStatus] = useState(null);
  const [stats, setStats] = useState({
    totalProducts: 0,
    lowStockProducts: 0,
    categories: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      
      // Check API health
      const health = await apiCall(healthAPI.checkHealth);
      setHealthStatus(health);
      
      // Get products data
      const products = await apiCall(productAPI.getAllProducts);
      if (products.success) {
        const productData = products.data.data || [];
        const categories = [...new Set(productData.map(p => p.category_id))];
        
        setStats({
          totalProducts: productData.length,
          lowStockProducts: productData.filter(p => p.stock_quantity <= 5).length,
          categories: categories.length,
        });
      }
      
      setLoading(false);
    };

    fetchData();
  }, []);

  const StatCard = ({ title, value, icon, color = "primary" }) => (
    <Card elevation={3} sx={{ height: '100%' }}>
      <CardContent>
        <Box display="flex" alignItems="center" justifyContent="space-between">
          <Box>
            <Typography color="textSecondary" gutterBottom variant="h6">
              {title}
            </Typography>
            <Typography variant="h4" component="div" color={color}>
              {value}
            </Typography>
          </Box>
          <Box color={`${color}.main`}>
            {icon}
          </Box>
        </Box>
      </CardContent>
    </Card>
  );

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="60vh">
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box>
      {/* Header */}
      <Box textAlign="center" mb={4}>
        <Typography variant="h3" component="h1" gutterBottom>
          Welcome to Online Shopping System
        </Typography>
        <Typography variant="h6" color="textSecondary" paragraph>
          A complete MySQL-based e-commerce platform with Node.js API
        </Typography>
        
        {/* Health Status */}
        <Box mt={2}>
          {healthStatus?.success ? (
            <Chip
              label="✅ API Server Online"
              color="success"
              variant="outlined"
            />
          ) : (
            <Chip
              label="❌ API Server Offline"
              color="error"
              variant="outlined"
            />
          )}
        </Box>
      </Box>

      {/* Statistics Cards */}
      <Grid container spacing={3} mb={4}>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Total Products"
            value={stats.totalProducts}
            icon={<Inventory fontSize="large" />}
            color="primary"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Low Stock Items"
            value={stats.lowStockProducts}
            icon={<TrendingUp fontSize="large" />}
            color="warning"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Categories"
            value={stats.categories}
            icon={<ShoppingCart fontSize="large" />}
            color="info"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Active Users"
            value="8"
            icon={<People fontSize="large" />}
            color="success"
          />
        </Grid>
      </Grid>

      {/* Features Section */}
      <Grid container spacing={3} mb={4}>
        <Grid item xs={12} md={6}>
          <Card elevation={2}>
            <CardContent>
              <Typography variant="h5" gutterBottom>
                🛒 E-Commerce Features
              </Typography>
              <Typography variant="body1" paragraph>
                Complete shopping system with product catalog, shopping cart, 
                order management, and real-time inventory tracking.
              </Typography>
              <Button variant="contained" href="/products">
                Browse Products
              </Button>
            </CardContent>
          </Card>
        </Grid>
        
        <Grid item xs={12} md={6}>
          <Card elevation={2}>
            <CardContent>
              <Typography variant="h5" gutterBottom>
                ⚙️ Admin Dashboard
              </Typography>
              <Typography variant="body1" paragraph>
                Manage products, track inventory, view orders, and analyze 
                sales data with comprehensive admin tools.
              </Typography>
              <Button variant="outlined" href="/admin">
                Admin Panel
              </Button>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Technical Stack */}
      <Card elevation={2}>
        <CardContent>
          <Typography variant="h5" gutterBottom>
            🚀 Technical Stack
          </Typography>
          <Grid container spacing={2}>
            <Grid item xs={12} sm={6} md={3}>
              <Typography variant="h6" color="primary">Frontend</Typography>
              <Typography variant="body2">
                • React.js<br/>
                • Material-UI<br/>
                • React Router<br/>
                • Axios
              </Typography>
            </Grid>
            <Grid item xs={12} sm={6} md={3}>
              <Typography variant="h6" color="primary">Backend</Typography>
              <Typography variant="body2">
                • Node.js<br/>
                • Express.js<br/>
                • MySQL2<br/>
                • RESTful API
              </Typography>
            </Grid>
            <Grid item xs={12} sm={6} md={3}>
              <Typography variant="h6" color="primary">Database</Typography>
              <Typography variant="body2">
                • MySQL/MariaDB<br/>
                • Stored Procedures<br/>
                • Triggers<br/>
                • Optimized Indexes
              </Typography>
            </Grid>
            <Grid item xs={12} sm={6} md={3}>
              <Typography variant="h6" color="primary">Features</Typography>
              <Typography variant="body2">
                • Stock Management<br/>
                • Order Processing<br/>
                • Real-time Updates<br/>
                • Admin Dashboard
              </Typography>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Quick Actions */}
      <Box mt={4} textAlign="center">
        <Typography variant="h5" gutterBottom>
          Quick Actions
        </Typography>
        <Box display="flex" gap={2} justifyContent="center" flexWrap="wrap">
          <Button variant="contained" href="/products" size="large">
            View Products
          </Button>
          <Button variant="outlined" href="/orders" size="large">
            Track Orders
          </Button>
          <Button variant="outlined" href="/admin" size="large">
            Admin Panel
          </Button>
        </Box>
      </Box>
    </Box>
  );
};

export default Home;
