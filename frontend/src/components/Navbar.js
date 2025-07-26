import React, { useState } from 'react';
import {
  AppBar,
  Toolbar,
  Typography,
  Button,
  IconButton,
  Badge,
  Menu,
  MenuItem,
  Box,
} from '@mui/material';
import {
  ShoppingCart,
  Store,
  AdminPanelSettings,
  Home,
  Receipt,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';

const Navbar = () => {
  const navigate = useNavigate();
  const [anchorEl, setAnchorEl] = useState(null);
  const [cartItems] = useState(3); // This will come from context later

  const handleMenuOpen = (event) => {
    setAnchorEl(event.currentTarget);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
  };

  const handleNavigation = (path) => {
    navigate(path);
    handleMenuClose();
  };

  return (
    <AppBar position="static" elevation={2}>
      <Toolbar>
        {/* Logo */}
        <IconButton
          edge="start"
          color="inherit"
          onClick={() => navigate('/')}
          sx={{ mr: 2 }}
        >
          <Store />
        </IconButton>
        
        <Typography
          variant="h6"
          component="div"
          sx={{ flexGrow: 1, cursor: 'pointer' }}
          onClick={() => navigate('/')}
        >
          Online Shopping System
        </Typography>

        {/* Navigation Buttons */}
        <Box sx={{ display: { xs: 'none', md: 'flex' }, gap: 1 }}>
          <Button
            color="inherit"
            startIcon={<Home />}
            onClick={() => navigate('/')}
          >
            Home
          </Button>
          
          <Button
            color="inherit"
            startIcon={<Store />}
            onClick={() => navigate('/products')}
          >
            Products
          </Button>
          
          <Button
            color="inherit"
            startIcon={<Receipt />}
            onClick={() => navigate('/orders')}
          >
            Orders
          </Button>
          
          <Button
            color="inherit"
            startIcon={<AdminPanelSettings />}
            onClick={() => navigate('/admin')}
          >
            Admin
          </Button>
        </Box>

        {/* Shopping Cart */}
        <IconButton
          color="inherit"
          onClick={() => navigate('/cart')}
          sx={{ ml: 2 }}
        >
          <Badge badgeContent={cartItems} color="secondary">
            <ShoppingCart />
          </Badge>
        </IconButton>

        {/* Mobile Menu */}
        <Box sx={{ display: { xs: 'flex', md: 'none' } }}>
          <Button
            color="inherit"
            onClick={handleMenuOpen}
          >
            Menu
          </Button>
          <Menu
            anchorEl={anchorEl}
            open={Boolean(anchorEl)}
            onClose={handleMenuClose}
          >
            <MenuItem onClick={() => handleNavigation('/')}>
              <Home sx={{ mr: 1 }} /> Home
            </MenuItem>
            <MenuItem onClick={() => handleNavigation('/products')}>
              <Store sx={{ mr: 1 }} /> Products
            </MenuItem>
            <MenuItem onClick={() => handleNavigation('/orders')}>
              <Receipt sx={{ mr: 1 }} /> Orders
            </MenuItem>
            <MenuItem onClick={() => handleNavigation('/admin')}>
              <AdminPanelSettings sx={{ mr: 1 }} /> Admin
            </MenuItem>
          </Menu>
        </Box>
      </Toolbar>
    </AppBar>
  );
};

export default Navbar;
