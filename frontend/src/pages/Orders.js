import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Card,
  CardContent,
  Button,
  Alert,
  Grid,
  Chip,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Accordion,
  AccordionSummary,
  AccordionDetails,
} from '@mui/material';
import {
  Receipt,
  LocalShipping,
  CheckCircle,
  AccessTime,
  ExpandMore,
} from '@mui/icons-material';
import { orderAPI, apiCall } from '../services/api';

const Orders = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    try {
      setLoading(true);
      // For demo purposes, using mock data since we don't have authentication yet
      const mockOrders = [
        {
          order_id: 1,
          customer_id: 1,
          customer_name: 'John Doe',
          order_date: '2024-01-15T10:30:00Z',
          order_status: 'Delivered',
          total_amount: 52000,
          order_details: [
            {
              order_detail_id: 1,
              product_id: 1,
              product_name: 'Laptop',
              quantity: 1,
              unit_price: 50000,
            },
            {
              order_detail_id: 2,
              product_id: 3,
              product_name: 'Headphones',
              quantity: 1,
              unit_price: 2000,
            },
          ],
        },
        {
          order_id: 2,
          customer_id: 1,
          customer_name: 'John Doe',
          order_date: '2024-01-20T14:15:00Z',
          order_status: 'Processing',
          total_amount: 25000,
          order_details: [
            {
              order_detail_id: 3,
              product_id: 2,
              product_name: 'Smartphone',
              quantity: 1,
              unit_price: 25000,
            },
          ],
        },
      ];
      setOrders(mockOrders);
    } catch (err) {
      setError('Failed to fetch orders');
      console.error('Error fetching orders:', err);
    } finally {
      setLoading(false);
    }
  };

  const getStatusIcon = (status) => {
    switch (status.toLowerCase()) {
      case 'delivered':
        return <CheckCircle color="success" />;
      case 'shipped':
        return <LocalShipping color="info" />;
      case 'processing':
        return <AccessTime color="warning" />;
      default:
        return <Receipt color="disabled" />;
    }
  };

  const getStatusColor = (status) => {
    switch (status.toLowerCase()) {
      case 'delivered':
        return 'success';
      case 'shipped':
        return 'info';
      case 'processing':
        return 'warning';
      case 'cancelled':
        return 'error';
      default:
        return 'default';
    }
  };

  const OrderCard = ({ order }) => (
    <Card elevation={2} sx={{ mb: 3 }}>
      <CardContent>
        <Grid container spacing={2} alignItems="center">
          <Grid item xs={12} sm={6}>
            <Box display="flex" alignItems="center" gap={1} mb={1}>
              {getStatusIcon(order.order_status)}
              <Typography variant="h6">
                Order #{order.order_id}
              </Typography>
            </Box>
            <Typography variant="body2" color="textSecondary">
              Ordered on: {new Date(order.order_date).toLocaleDateString()}
            </Typography>
          </Grid>
          
          <Grid item xs={12} sm={3}>
            <Chip
              label={order.order_status}
              color={getStatusColor(order.order_status)}
              size="small"
            />
          </Grid>
          
          <Grid item xs={12} sm={3}>
            <Typography variant="h6" color="primary" align="right">
              ₹{order.total_amount.toLocaleString()}
            </Typography>
          </Grid>
        </Grid>

        <Accordion sx={{ mt: 2 }}>
          <AccordionSummary expandIcon={<ExpandMore />}>
            <Typography>Order Details ({order.order_details.length} items)</Typography>
          </AccordionSummary>
          <AccordionDetails>
            <TableContainer component={Paper} variant="outlined">
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Product</TableCell>
                    <TableCell align="center">Quantity</TableCell>
                    <TableCell align="right">Unit Price</TableCell>
                    <TableCell align="right">Total</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {order.order_details.map((detail) => (
                    <TableRow key={detail.order_detail_id}>
                      <TableCell>{detail.product_name}</TableCell>
                      <TableCell align="center">{detail.quantity}</TableCell>
                      <TableCell align="right">
                        ₹{detail.unit_price.toLocaleString()}
                      </TableCell>
                      <TableCell align="right">
                        ₹{(detail.quantity * detail.unit_price).toLocaleString()}
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          </AccordionDetails>
        </Accordion>

        <Box display="flex" gap={1} mt={2}>
          <Button
            variant="outlined"
            size="small"
            onClick={() => {
              alert(`Track order #${order.order_id}`);
            }}
          >
            Track Order
          </Button>
          <Button
            variant="outlined"
            size="small"
            onClick={() => {
              alert(`Download invoice for order #${order.order_id}`);
            }}
          >
            Download Invoice
          </Button>
          {order.order_status.toLowerCase() === 'processing' && (
            <Button
              variant="outlined"
              color="error"
              size="small"
              onClick={() => {
                if (window.confirm('Are you sure you want to cancel this order?')) {
                  alert(`Cancel order #${order.order_id}`);
                }
              }}
            >
              Cancel Order
            </Button>
          )}
        </Box>
      </CardContent>
    </Card>
  );

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <Typography>Loading orders...</Typography>
      </Box>
    );
  }

  return (
    <Box>
      <Typography variant="h4" component="h1" gutterBottom>
        My Orders
      </Typography>

      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}

      {orders.length === 0 ? (
        <Alert severity="info" sx={{ mt: 2 }}>
          You haven't placed any orders yet. <Button href="/products">Start Shopping</Button>
        </Alert>
      ) : (
        <Box>
          <Typography variant="body1" color="textSecondary" gutterBottom>
            You have {orders.length} order(s)
          </Typography>
          
          {orders.map((order) => (
            <OrderCard key={order.order_id} order={order} />
          ))}
        </Box>
      )}
    </Box>
  );
};

export default Orders;
