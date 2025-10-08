package org.acme.examples;

import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/**
 * 🚀 ADVANCED ENDPOINT EXAMPLES
 * ===============================
 * 
 * This class demonstrates advanced patterns for REST APIs:
 * - Filtering and pagination
 * - Error handling
 * - Validation
 * - Complex endpoints
 * - Different response types
 */
@Path("/examples")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ExamplesResource {

    // Simulated database with thread-safety for Lambda
    private static final Map<Long, User> users = new ConcurrentHashMap<>();
    private static final Map<Long, List<Order>> userOrders = new ConcurrentHashMap<>();
    private static Long nextUserId = 1L;
    private static Long nextOrderId = 1L;

    static {
        // Example data
        initializeData();
    }

    // ========================================================================
    // 👥 USER MANAGEMENT
    // ========================================================================

    /**
     * 📋 GET /examples/users - User list with filters and pagination
     * 
     * @param page Page number (default: 0)
     * @param size Page size (default: 10, max: 100)
     * @param status Filter by status (optional)
     * @param search Search in name/email (optional)
     * @return User page with metadata
     */
    @GET
    @Path("/users")
    public PagedResponse<User> getUsers(
            @QueryParam("page") @DefaultValue("0") int page,
            @QueryParam("size") @DefaultValue("10") int size,
            @QueryParam("status") String status,
            @QueryParam("search") String search) {

        // Parameter validation
        if (page < 0) page = 0;
        if (size < 1 || size > 100) size = 10;

        List<User> allUsers = new ArrayList<>(users.values());

        // Filtering
        if (status != null && !status.isEmpty()) {
            allUsers = allUsers.stream()
                .filter(user -> status.equalsIgnoreCase(user.status))
                .collect(Collectors.toList());
        }

        if (search != null && !search.trim().isEmpty()) {
            String searchLower = search.toLowerCase();
            allUsers = allUsers.stream()
                .filter(user -> 
                    user.name.toLowerCase().contains(searchLower) ||
                    user.email.toLowerCase().contains(searchLower))
                .collect(Collectors.toList());
        }

        // Pagination
        int totalElements = allUsers.size();
        int totalPages = (int) Math.ceil((double) totalElements / size);
        int start = page * size;
        int end = Math.min(start + size, totalElements);

        List<User> pageContent = allUsers.subList(start, end);

        return new PagedResponse<>(
            pageContent,
            page,
            size,
            totalElements,
            totalPages
        );
    }

    /**
     * 👤 GET /examples/users/{id} - Utilisateur avec ses commandes
     */
    @GET
    @Path("/users/{id}")
    public UserWithOrders getUserWithOrders(@PathParam("id") Long id) {
        User user = users.get(id);
        if (user == null) {
            throw new NotFoundException("Utilisateur " + id + " introuvable");
        }

        List<Order> orders = userOrders.getOrDefault(id, new ArrayList<>());
        return new UserWithOrders(user, orders);
    }

    /**
     * ➕ POST /examples/users - Création d'utilisateur avec validation
     */
    @POST
    @Path("/users")
    public Response createUser(CreateUserRequest request) {
        // Validation
        List<String> errors = validateUserRequest(request);
        if (!errors.isEmpty()) {
            return Response.status(400)
                .entity(new ValidationErrorResponse(errors))
                .build();
        }

        // Check email uniqueness
        boolean emailExists = users.values().stream()
            .anyMatch(user -> user.email.equalsIgnoreCase(request.email));
        
        if (emailExists) {
            return Response.status(409)
                .entity(new ErrorResponse("Email déjà utilisé"))
                .build();
        }

        // Creation
        User user = new User(
            nextUserId++,
            request.name,
            request.email,
            "ACTIVE",
            LocalDateTime.now()
        );
        users.put(user.id, user);

        return Response.status(201)
            .entity(user)
            .build();
    }

    // ========================================================================
    // 🛒 ORDER MANAGEMENT
    // ========================================================================

    /**
     * 📦 GET /examples/users/{userId}/orders - Commandes d'un utilisateur
     */
    @GET
    @Path("/users/{userId}/orders")
    public List<Order> getUserOrders(@PathParam("userId") Long userId) {
        if (!users.containsKey(userId)) {
            throw new NotFoundException("Utilisateur " + userId + " introuvable");
        }
        return userOrders.getOrDefault(userId, new ArrayList<>());
    }

    /**
     * 🛍️ POST /examples/users/{userId}/orders - Nouvelle commande
     */
    @POST
    @Path("/users/{userId}/orders")
    public Response createOrder(@PathParam("userId") Long userId, CreateOrderRequest request) {
        if (!users.containsKey(userId)) {
            throw new NotFoundException("Utilisateur " + userId + " introuvable");
        }

        if (request.items == null || request.items.isEmpty()) {
            return Response.status(400)
                .entity(new ErrorResponse("La commande doit contenir au moins un article"))
                .build();
        }

        // Calculate total
        double total = request.items.stream()
            .mapToDouble(item -> item.price * item.quantity)
            .sum();

        Order order = new Order(
            nextOrderId++,
            userId,
            request.items,
            total,
            "PENDING",
            LocalDateTime.now()
        );

        userOrders.computeIfAbsent(userId, k -> new ArrayList<>()).add(order);

        return Response.status(201)
            .entity(order)
            .build();
    }

    // ========================================================================
    // 📊 STATISTICS AND REPORTS
    // ========================================================================

    /**
     * 📈 GET /examples/stats - Statistiques globales
     */
    @GET
    @Path("/stats")
    public StatsResponse getStats() {
        int totalUsers = users.size();
        int activeUsers = (int) users.values().stream()
            .filter(user -> "ACTIVE".equals(user.status))
            .count();

        int totalOrders = userOrders.values().stream()
            .mapToInt(List::size)
            .sum();

        double totalRevenue = userOrders.values().stream()
            .flatMap(List::stream)
            .mapToDouble(order -> order.total)
            .sum();

        return new StatsResponse(totalUsers, activeUsers, totalOrders, totalRevenue);
    }

    /**
     * 🏆 GET /examples/users/top - Top 5 des utilisateurs par nombre de commandes
     */
    @GET
    @Path("/users/top")
    public List<UserStats> getTopUsers() {
        return users.values().stream()
            .map(user -> {
                List<Order> orders = userOrders.getOrDefault(user.id, new ArrayList<>());
                double totalSpent = orders.stream().mapToDouble(o -> o.total).sum();
                return new UserStats(user, orders.size(), totalSpent);
            })
            .sorted((a, b) -> Integer.compare(b.orderCount, a.orderCount))
            .limit(5)
            .collect(Collectors.toList());
    }

    // ========================================================================
    // 🔧 UTILITY ENDPOINTS
    // ========================================================================

    /**
     * 💚 GET /examples/health - Health check détaillé
     */
    @GET
    @Path("/health")
    public HealthResponse health() {
        // Vérifications système
        long memoryUsed = Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory();
        long memoryTotal = Runtime.getRuntime().totalMemory();
        double memoryUsagePercent = (double) memoryUsed / memoryTotal * 100;

        Map<String, Object> checks = new HashMap<>();
        checks.put("memory_usage_percent", Math.round(memoryUsagePercent * 100.0) / 100.0);
        checks.put("users_count", users.size());
        checks.put("orders_count", userOrders.values().stream().mapToInt(List::size).sum());

        String status = memoryUsagePercent > 90 ? "WARN" : "OK";

        return new HealthResponse(status, LocalDateTime.now(), checks);
    }

    /**
     * 🧹 DELETE /examples/reset - Reset des données (dev seulement)
     */
    @DELETE
    @Path("/reset")
    public Response resetData() {
        users.clear();
        userOrders.clear();
        nextUserId = 1L;
        nextOrderId = 1L;
        initializeData();

        return Response.ok()
            .entity(new MessageResponse("Données réinitialisées"))
            .build();
    }

    // ========================================================================
    // MÉTHODES PRIVÉES
    // ========================================================================

    private static void initializeData() {
        // Utilisateurs d'exemple
        users.put(1L, new User(1L, "Alice Dupont", "alice@example.com", "ACTIVE", LocalDateTime.now().minusDays(30)));
        users.put(2L, new User(2L, "Bob Martin", "bob@example.com", "ACTIVE", LocalDateTime.now().minusDays(15)));
        users.put(3L, new User(3L, "Claire Durand", "claire@example.com", "INACTIVE", LocalDateTime.now().minusDays(5)));
        nextUserId = 4L;

        // Commandes d'exemple
        List<OrderItem> items1 = Arrays.asList(
            new OrderItem("Laptop", 1, 999.99),
            new OrderItem("Souris", 1, 29.99)
        );
        userOrders.put(1L, Arrays.asList(
            new Order(1L, 1L, items1, 1029.98, "COMPLETED", LocalDateTime.now().minusDays(10))
        ));

        List<OrderItem> items2 = Arrays.asList(
            new OrderItem("Clavier", 1, 89.99)
        );
        userOrders.put(2L, Arrays.asList(
            new Order(2L, 2L, items2, 89.99, "PENDING", LocalDateTime.now().minusDays(2))
        ));

        nextOrderId = 3L;
    }

    private List<String> validateUserRequest(CreateUserRequest request) {
        List<String> errors = new ArrayList<>();

        if (request.name == null || request.name.trim().isEmpty()) {
            errors.add("Le nom est obligatoire");
        } else if (request.name.length() > 100) {
            errors.add("Le nom ne peut pas dépasser 100 caractères");
        }

        if (request.email == null || request.email.trim().isEmpty()) {
            errors.add("L'email est obligatoire");
        } else if (!isValidEmail(request.email)) {
            errors.add("Format d'email invalide");
        }

        return errors;
    }

    private boolean isValidEmail(String email) {
        return email.contains("@") && email.contains(".");
    }

    // ========================================================================
    // CLASSES INTERNES - ENTITÉS ET RÉPONSES
    // ========================================================================

    public static class User {
        public Long id;
        public String name;
        public String email;
        public String status;
        public LocalDateTime createdAt;

        public User() {}

        public User(Long id, String name, String email, String status, LocalDateTime createdAt) {
            this.id = id;
            this.name = name;
            this.email = email;
            this.status = status;
            this.createdAt = createdAt;
        }
    }

    public static class Order {
        public Long id;
        public Long userId;
        public List<OrderItem> items;
        public double total;
        public String status;
        public LocalDateTime createdAt;

        public Order() {}

        public Order(Long id, Long userId, List<OrderItem> items, double total, String status, LocalDateTime createdAt) {
            this.id = id;
            this.userId = userId;
            this.items = items;
            this.total = total;
            this.status = status;
            this.createdAt = createdAt;
        }
    }

    public static class OrderItem {
        public String name;
        public int quantity;
        public double price;

        public OrderItem() {}

        public OrderItem(String name, int quantity, double price) {
            this.name = name;
            this.quantity = quantity;
            this.price = price;
        }
    }

    public static class PagedResponse<T> {
        public List<T> content;
        public int page;
        public int size;
        public int totalElements;
        public int totalPages;

        public PagedResponse(List<T> content, int page, int size, int totalElements, int totalPages) {
            this.content = content;
            this.page = page;
            this.size = size;
            this.totalElements = totalElements;
            this.totalPages = totalPages;
        }
    }

    public static class UserWithOrders {
        public User user;
        public List<Order> orders;

        public UserWithOrders(User user, List<Order> orders) {
            this.user = user;
            this.orders = orders;
        }
    }

    public static class UserStats {
        public User user;
        public int orderCount;
        public double totalSpent;

        public UserStats(User user, int orderCount, double totalSpent) {
            this.user = user;
            this.orderCount = orderCount;
            this.totalSpent = totalSpent;
        }
    }

    public static class CreateUserRequest {
        public String name;
        public String email;
    }

    public static class CreateOrderRequest {
        public List<OrderItem> items;
    }

    public static class StatsResponse {
        public int totalUsers;
        public int activeUsers;
        public int totalOrders;
        public double totalRevenue;

        public StatsResponse(int totalUsers, int activeUsers, int totalOrders, double totalRevenue) {
            this.totalUsers = totalUsers;
            this.activeUsers = activeUsers;
            this.totalOrders = totalOrders;
            this.totalRevenue = totalRevenue;
        }
    }

    public static class HealthResponse {
        public String status;
        public LocalDateTime timestamp;
        public Map<String, Object> checks;

        public HealthResponse(String status, LocalDateTime timestamp, Map<String, Object> checks) {
            this.status = status;
            this.timestamp = timestamp;
            this.checks = checks;
        }
    }

    public static class ErrorResponse {
        public String error;
        public long timestamp;

        public ErrorResponse(String error) {
            this.error = error;
            this.timestamp = System.currentTimeMillis();
        }
    }

    public static class ValidationErrorResponse {
        public List<String> errors;
        public long timestamp;

        public ValidationErrorResponse(List<String> errors) {
            this.errors = errors;
            this.timestamp = System.currentTimeMillis();
        }
    }

    public static class MessageResponse {
        public String message;
        public long timestamp;

        public MessageResponse(String message) {
            this.message = message;
            this.timestamp = System.currentTimeMillis();
        }
    }
}

/*
 * ============================================================================
 * 🧪 EXEMPLES D'UTILISATION AVANCÉS
 * ============================================================================
 * 
 * # URL de base
 * LAMBDA_URL="https://xxx.lambda-url.region.on.aws"
 * 
 * # Pagination et filtrage
 * curl "$LAMBDA_URL/examples/users?page=0&size=5&status=ACTIVE&search=alice"
 * 
 * # Création d'utilisateur
 * curl -X POST $LAMBDA_URL/examples/users \
 *   -H "Content-Type: application/json" \
 *   -d '{"name":"Jean Dupont","email":"jean@example.com"}'
 * 
 * # Utilisateur avec ses commandes
 * curl $LAMBDA_URL/examples/users/1
 * 
 * # Nouvelle commande
 * curl -X POST $LAMBDA_URL/examples/users/1/orders \
 *   -H "Content-Type: application/json" \
 *   -d '{"items":[{"name":"Téléphone","quantity":1,"price":599.99}]}'
 * 
 * # Statistiques
 * curl $LAMBDA_URL/examples/stats
 * 
 * # Top utilisateurs
 * curl $LAMBDA_URL/examples/users/top
 * 
 * # Health check
 * curl $LAMBDA_URL/examples/health
 * 
 * ============================================================================
 */