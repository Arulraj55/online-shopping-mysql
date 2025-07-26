import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Card,
  CardContent,
  Button,
  CircularProgress,
  Alert,
  Chip,
  Grid,
} from '@mui/material';
import { useParams, useNavigate } from 'react-router-dom';
import {
  ArrowBack,
  ShoppingCart,
  AttachMoney,
  Inventory,
  Category,
} from '@mui/icons-material';
import { productAPI, apiCall } from '../services/api';

const ProductDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [product, setProduct] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchProduct();
  }, [id]);

  const fetchProduct = async () => {
    setLoading(true);
    setError(null);
    
    const result = await apiCall(productAPI.getProductById, id);
    
    if (result.success) {
      setProduct(result.data.data);
    } else {
      setError(result.error || 'Failed to fetch product details');
    }
    
    setLoading(false);
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="60vh">
        <CircularProgress />
      </Box>
    );
  }

  if (error) {
    return (
      <Alert severity="error" sx={{ mt: 2 }}>
        {error}
        <Button onClick={fetchProduct} sx={{ ml: 2 }}>
          Retry
        </Button>
      </Alert>
    );
  }

  if (!product) {
    return (
      <Alert severity="warning" sx={{ mt: 2 }}>
        Product not found
      </Alert>
    );
  }

  return (
    <Box>
      {/* Back Button */}
      <Button
        startIcon={<ArrowBack />}
        onClick={() => navigate('/products')}
        sx={{ mb: 2 }}
      >
        Back to Products
      </Button>

      <Grid container spacing={4}>
        {/* Product Image */}
        <Grid item xs={12} md={6}>
          <Card elevation={2}>
            <Box
              sx={{
                height: 400,
                background: 'linear-gradient(45deg, #f0f0f0 25%, transparent 25%), linear-gradient(-45deg, #f0f0f0 25%, transparent 25%), linear-gradient(45deg, transparent 75%, #f0f0f0 75%), linear-gradient(-45deg, transparent 75%, #f0f0f0 75%)',
                backgroundSize: '20px 20px',
                backgroundPosition: '0 0, 0 10px, 10px -10px, -10px 0px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: '#666'
              }}
            >
              <Typography variant="h1">📦</Typography>
            </Box>
          </Card>
        </Grid>

        {/* Product Details */}
        <Grid item xs={12} md={6}>
          <Box>
            <Typography variant="h4" component="h1" gutterBottom>
              {product.product_name}
            </Typography>

            {/* Category */}
            <Box display="flex" alignItems="center" gap={1} mb={2}>
              <Category color="primary" />
              <Chip 
                label={product.category_name || `Category ${product.category_id}`}
                variant="outlined"
                color="primary"
              />
            </Box>

            {/* Price */}
            <Box display="flex" alignItems="center" gap={1} mb={3}>
              <AttachMoney color="success" fontSize="large" />
              <Typography variant="h3" color="primary" fontWeight="bold">
                ₹{parseFloat(product.price).toLocaleString()}
              </Typography>
            </Box>

            {/* Stock Status */}
            <Box display="flex" alignItems="center" gap={1} mb={3}>
              <Inventory />
              <Typography variant="h6">
                Stock: {product.stock_quantity} units
              </Typography>
              {product.stock_quantity <= 5 && product.stock_quantity > 0 && (
                <Chip 
                  label="Low Stock" 
                  color="warning" 
                  variant="outlined"
                />
              )}
              {product.stock_quantity === 0 && (
                <Chip 
                  label="Out of Stock" 
                  color="error" 
                  variant="outlined"
                />
              )}
            </Box>

            {/* Description */}
            <Card elevation={1} sx={{ mb: 3 }}>
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  Description
                </Typography>
                <Typography variant="body1">
                  {product.description || 'No description available for this product.'}
                </Typography>
              </CardContent>
            </Card>

            {/* Actions */}
            <Box display="flex" gap={2}>
              <Button
                variant="contained"
                size="large"
                startIcon={<ShoppingCart />}
                disabled={product.stock_quantity === 0}
                onClick={() => {
                  alert(`Added ${product.product_name} to cart!`);
                }}
                sx={{ flexGrow: 1 }}
              >
                {product.stock_quantity === 0 ? 'Out of Stock' : 'Add to Cart'}
              </Button>
            </Box>

            {/* Product Info */}
            <Card elevation={1} sx={{ mt: 3 }}>
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  Product Information
                </Typography>
                <Grid container spacing={2}>
                  <Grid item xs={6}>
                    <Typography variant="body2" color="textSecondary">
                      Product ID
                    </Typography>
                    <Typography variant="body1">
                      #{product.product_id}
                    </Typography>
                  </Grid>
                  <Grid item xs={6}>
                    <Typography variant="body2" color="textSecondary">
                      SKU
                    </Typography>
                    <Typography variant="body1">
                      {product.sku || 'N/A'}
                    </Typography>
                  </Grid>
                  <Grid item xs={6}>
                    <Typography variant="body2" color="textSecondary">
                      Status
                    </Typography>
                    <Typography variant="body1">
                      {product.is_active ? 'Active' : 'Inactive'}
                    </Typography>
                  </Grid>
                  <Grid item xs={6}>
                    <Typography variant="body2" color="textSecondary">
                      Category ID
                    </Typography>
                    <Typography variant="body1">
                      {product.category_id}
                    </Typography>
                  </Grid>
                </Grid>
              </CardContent>
            </Card>
          </Box>
        </Grid>
      </Grid>
    </Box>
  );
};

export default ProductDetail;
