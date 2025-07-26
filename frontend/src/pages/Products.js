import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Grid,
  Card,
  CardContent,
  CardMedia,
  Button,
  CircularProgress,
  Alert,
  Chip,
  TextField,
  InputAdornment,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
} from '@mui/material';
import {
  Search,
  ShoppingCart,
  AttachMoney,
  Inventory,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { productAPI, apiCall } from '../services/api';

const Products = () => {
  const navigate = useNavigate();
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [sortBy, setSortBy] = useState('name');
  const [filterCategory, setFilterCategory] = useState('all');

  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    setLoading(true);
    setError(null);
    
    const result = await apiCall(productAPI.getAllProducts);
    
    if (result.success) {
      setProducts(result.data.data || []);
    } else {
      setError(result.error || 'Failed to fetch products');
    }
    
    setLoading(false);
  };

  const filteredAndSortedProducts = products
    .filter(product => {
      const matchesSearch = product.product_name
        .toLowerCase()
        .includes(searchTerm.toLowerCase());
      const matchesCategory = filterCategory === 'all' || 
        product.category_id === parseInt(filterCategory);
      return matchesSearch && matchesCategory;
    })
    .sort((a, b) => {
      switch (sortBy) {
        case 'name':
          return a.product_name.localeCompare(b.product_name);
        case 'price_low':
          return parseFloat(a.price) - parseFloat(b.price);
        case 'price_high':
          return parseFloat(b.price) - parseFloat(a.price);
        case 'stock':
          return b.stock_quantity - a.stock_quantity;
        default:
          return 0;
      }
    });

  const categories = [...new Set(products.map(p => ({
    id: p.category_id,
    name: p.category_name
  })))];

  const ProductCard = ({ product }) => (
    <Card 
      elevation={2} 
      sx={{ 
        height: '100%', 
        display: 'flex', 
        flexDirection: 'column',
        cursor: 'pointer',
        '&:hover': {
          elevation: 4,
          transform: 'translateY(-2px)',
          transition: 'all 0.3s ease-in-out'
        }
      }}
      onClick={() => navigate(`/products/${product.product_id}`)}
    >
      <CardMedia
        component="div"
        sx={{
          height: 200,
          background: 'linear-gradient(45deg, #f0f0f0 25%, transparent 25%), linear-gradient(-45deg, #f0f0f0 25%, transparent 25%), linear-gradient(45deg, transparent 75%, #f0f0f0 75%), linear-gradient(-45deg, transparent 75%, #f0f0f0 75%)',
          backgroundSize: '20px 20px',
          backgroundPosition: '0 0, 0 10px, 10px -10px, -10px 0px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          color: '#666'
        }}
      >
        <Typography variant="h6">📦</Typography>
      </CardMedia>
      
      <CardContent sx={{ flexGrow: 1 }}>
        <Typography gutterBottom variant="h6" component="div" noWrap>
          {product.product_name}
        </Typography>
        
        <Typography variant="body2" color="text.secondary" paragraph>
          {product.description || 'No description available'}
        </Typography>
        
        <Box display="flex" alignItems="center" gap={1} mb={1}>
          <AttachMoney color="primary" fontSize="small" />
          <Typography variant="h6" color="primary">
            ₹{parseFloat(product.price).toLocaleString()}
          </Typography>
        </Box>
        
        <Box display="flex" alignItems="center" gap={1} mb={2}>
          <Inventory fontSize="small" />
          <Typography variant="body2">
            Stock: {product.stock_quantity}
          </Typography>
          {product.stock_quantity <= 5 && (
            <Chip 
              label="Low Stock" 
              size="small" 
              color="warning" 
              variant="outlined"
            />
          )}
          {product.stock_quantity === 0 && (
            <Chip 
              label="Out of Stock" 
              size="small" 
              color="error" 
              variant="outlined"
            />
          )}
        </Box>
        
        <Box display="flex" gap={1}>
          <Button
            variant="contained"
            startIcon={<ShoppingCart />}
            fullWidth
            disabled={product.stock_quantity === 0}
            onClick={(e) => {
              e.stopPropagation();
              // Add to cart logic here
              alert(`Added ${product.product_name} to cart!`);
            }}
          >
            Add to Cart
          </Button>
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

  if (error) {
    return (
      <Alert severity="error" sx={{ mt: 2 }}>
        {error}
        <Button onClick={fetchProducts} sx={{ ml: 2 }}>
          Retry
        </Button>
      </Alert>
    );
  }

  return (
    <Box>
      {/* Header */}
      <Typography variant="h4" component="h1" gutterBottom>
        Products Catalog
      </Typography>
      <Typography variant="body1" color="textSecondary" paragraph>
        Browse our collection of {products.length} products
      </Typography>

      {/* Search and Filter Controls */}
      <Box mb={3}>
        <Grid container spacing={2}>
          <Grid item xs={12} md={6}>
            <TextField
              fullWidth
              variant="outlined"
              placeholder="Search products..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <Search />
                  </InputAdornment>
                ),
              }}
            />
          </Grid>
          
          <Grid item xs={12} sm={6} md={3}>
            <FormControl fullWidth>
              <InputLabel>Sort By</InputLabel>
              <Select
                value={sortBy}
                label="Sort By"
                onChange={(e) => setSortBy(e.target.value)}
              >
                <MenuItem value="name">Name (A-Z)</MenuItem>
                <MenuItem value="price_low">Price (Low to High)</MenuItem>
                <MenuItem value="price_high">Price (High to Low)</MenuItem>
                <MenuItem value="stock">Stock Level</MenuItem>
              </Select>
            </FormControl>
          </Grid>
          
          <Grid item xs={12} sm={6} md={3}>
            <FormControl fullWidth>
              <InputLabel>Category</InputLabel>
              <Select
                value={filterCategory}
                label="Category"
                onChange={(e) => setFilterCategory(e.target.value)}
              >
                <MenuItem value="all">All Categories</MenuItem>
                {categories.map((category) => (
                  <MenuItem key={category.id} value={category.id}>
                    {category.name || `Category ${category.id}`}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </Grid>
        </Grid>
      </Box>

      {/* Results Summary */}
      <Box mb={2}>
        <Typography variant="body2" color="textSecondary">
          Showing {filteredAndSortedProducts.length} of {products.length} products
        </Typography>
      </Box>

      {/* Products Grid */}
      {filteredAndSortedProducts.length === 0 ? (
        <Alert severity="info">
          No products found matching your criteria.
        </Alert>
      ) : (
        <Grid container spacing={3}>
          {filteredAndSortedProducts.map((product) => (
            <Grid item xs={12} sm={6} md={4} lg={3} key={product.product_id}>
              <ProductCard product={product} />
            </Grid>
          ))}
        </Grid>
      )}
    </Box>
  );
};

export default Products;
