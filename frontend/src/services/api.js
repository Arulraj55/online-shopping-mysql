// API Service for Online Shopping System
import axios from 'axios';

const API_BASE_URL = 'http://localhost:3000/api';

// Create axios instance with default config
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor for adding auth token (future use)
api.interceptors.request.use(
  (config) => {
    // Add auth token when available
    const token = localStorage.getItem('authToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    if (error.response?.status === 401) {
      // Handle unauthorized access
      localStorage.removeItem('authToken');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Product API calls
export const productAPI = {
  // Get all products
  getAllProducts: () => api.get('/products'),
  
  // Get product by ID
  getProductById: (id) => api.get(`/products/${id}`),
  
  // Create new product
  createProduct: (productData) => api.post('/products', productData),
  
  // Update product
  updateProduct: (id, productData) => api.put(`/products/${id}`, productData),
  
  // Delete product
  deleteProduct: (id) => api.delete(`/products/${id}`),
  
  // Get low stock products
  getLowStockProducts: (threshold = 5) => api.get(`/products/low-stock?threshold=${threshold}`),
  
  // Get products by category
  getProductsByCategory: (categoryId) => api.get(`/products/category/${categoryId}`),
};

// Customer API calls
export const customerAPI = {
  getAllCustomers: () => api.get('/customers'),
  getCustomerById: (id) => api.get(`/customers/${id}`),
  createCustomer: (customerData) => api.post('/customers', customerData),
  updateCustomer: (id, customerData) => api.put(`/customers/${id}`, customerData),
  deleteCustomer: (id) => api.delete(`/customers/${id}`),
};

// Order API calls
export const orderAPI = {
  getAllOrders: () => api.get('/orders'),
  getOrderById: (id) => api.get(`/orders/${id}`),
  createOrder: (orderData) => api.post('/orders', orderData),
  updateOrderStatus: (id, status) => api.put(`/orders/${id}/status`, { status }),
  cancelOrder: (id) => api.delete(`/orders/${id}`),
};

// Health check
export const healthAPI = {
  checkHealth: () => axios.get('http://localhost:3000/health'),
  checkDatabaseHealth: () => axios.get('http://localhost:3000/health/db'),
};

// Generic API call function
export const apiCall = async (apiFunction, ...args) => {
  try {
    const response = await apiFunction(...args);
    return {
      success: true,
      data: response.data,
      status: response.status,
    };
  } catch (error) {
    console.error('API Call Error:', error);
    return {
      success: false,
      error: error.response?.data?.message || error.message,
      status: error.response?.status || 500,
    };
  }
};

export default api;
