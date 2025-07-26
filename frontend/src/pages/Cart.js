import React from 'react';
import {
  Box,
  Typography,
  Card,
  CardContent,
  Button,
  Alert,
  Grid,
  Divider,
} from '@mui/material';
import {
  ShoppingCart,
  Remove,
  Add,
  Delete,
  Payment,
} from '@mui/icons-material';

const Cart = () => {
  // Mock cart data - this would come from context/state management
  const cartItems = [
    {
      id: 1,
      product_id: 1,
      product_name: 'Laptop',
      price: 50000,
      quantity: 1,
      stock_quantity: 10,
    },
    {
      id: 2,
      product_id: 3,
      product_name: 'Headphones',
      price: 2000,
      quantity: 2,
      stock_quantity: 15,
    },
  ];

  const total = cartItems.reduce((sum, item) => sum + (item.price * item.quantity), 0);

  const CartItem = ({ item }) => (
    <Card elevation={1} sx={{ mb: 2 }}>
      <CardContent>
        <Grid container spacing={2} alignItems="center">
          <Grid item xs={12} sm={6}>
            <Typography variant="h6">
              {item.product_name}
            </Typography>
            <Typography variant="body2" color="textSecondary">
              ₹{item.price.toLocaleString()} each
            </Typography>
          </Grid>
          
          <Grid item xs={12} sm={3}>
            <Box display="flex" alignItems="center" gap={1}>
              <Button
                size="small"
                onClick={() => {
                  // Decrease quantity logic
                }}
              >
                <Remove />
              </Button>
              <Typography variant="h6" sx={{ minWidth: 40, textAlign: 'center' }}>
                {item.quantity}
              </Typography>
              <Button
                size="small"
                onClick={() => {
                  // Increase quantity logic
                }}
              >
                <Add />
              </Button>
            </Box>
          </Grid>
          
          <Grid item xs={12} sm={2}>
            <Typography variant="h6" color="primary">
              ₹{(item.price * item.quantity).toLocaleString()}
            </Typography>
          </Grid>
          
          <Grid item xs={12} sm={1}>
            <Button
              color="error"
              onClick={() => {
                // Remove item logic
              }}
            >
              <Delete />
            </Button>
          </Grid>
        </Grid>
      </CardContent>
    </Card>
  );

  return (
    <Box>
      <Typography variant="h4" component="h1" gutterBottom>
        Shopping Cart
      </Typography>

      {cartItems.length === 0 ? (
        <Alert severity="info" sx={{ mt: 2 }}>
          Your cart is empty. <Button href="/products">Start Shopping</Button>
        </Alert>
      ) : (
        <Grid container spacing={3}>
          {/* Cart Items */}
          <Grid item xs={12} md={8}>
            <Typography variant="h6" gutterBottom>
              Cart Items ({cartItems.length})
            </Typography>
            
            {cartItems.map((item) => (
              <CartItem key={item.id} item={item} />
            ))}
          </Grid>

          {/* Order Summary */}
          <Grid item xs={12} md={4}>
            <Card elevation={2}>
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  Order Summary
                </Typography>
                
                <Box display="flex" justifyContent="space-between" mb={1}>
                  <Typography>Subtotal:</Typography>
                  <Typography>₹{total.toLocaleString()}</Typography>
                </Box>
                
                <Box display="flex" justifyContent="space-between" mb={1}>
                  <Typography>Shipping:</Typography>
                  <Typography>₹0</Typography>
                </Box>
                
                <Box display="flex" justifyContent="space-between" mb={1}>
                  <Typography>Tax:</Typography>
                  <Typography>₹{Math.round(total * 0.18).toLocaleString()}</Typography>
                </Box>
                
                <Divider sx={{ my: 2 }} />
                
                <Box display="flex" justifyContent="space-between" mb={3}>
                  <Typography variant="h6">Total:</Typography>
                  <Typography variant="h6" color="primary">
                    ₹{Math.round(total * 1.18).toLocaleString()}
                  </Typography>
                </Box>
                
                <Button
                  variant="contained"
                  fullWidth
                  size="large"
                  startIcon={<Payment />}
                  onClick={() => {
                    alert('Checkout functionality will be implemented!');
                  }}
                >
                  Proceed to Checkout
                </Button>
                
                <Button
                  variant="outlined"
                  fullWidth
                  sx={{ mt: 1 }}
                  href="/products"
                >
                  Continue Shopping
                </Button>
              </CardContent>
            </Card>
          </Grid>
        </Grid>
      )}
    </Box>
  );
};

export default Cart;
