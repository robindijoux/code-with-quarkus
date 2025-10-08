package org.acme.template;

import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * 📄 TEMPLATE D'ENDPOINT REST
 * ============================
 * 
 * Ce fichier est un template pour créer de nouveaux endpoints.
 * 
 * 🔄 POUR CRÉER UN NOUVEL ENDPOINT :
 * 1. Copiez ce fichier vers src/main/java/VOTRE_PACKAGE/resource/
 * 2. Renommez la classe (ex: UserResource, ProductResource)
 * 3. Changez le @Path (ex: "/users", "/products")
 * 4. Adaptez l'entité (remplacez TemplateEntity)
 * 5. Implémentez votre logique métier
 * 
 * 🏗️ STRUCTURE RECOMMANDÉE :
 * - model/      : Entités/DTOs
 * - resource/   : Endpoints REST (cette classe)
 * - service/    : Logique métier
 * - exception/  : Gestion d'erreurs
 * 
 * 🧪 TESTS AUTOMATIQUES :
 * Une fois déployé, votre endpoint sera disponible à :
 * https://LAMBDA-URL/votre-path
 */
@Path("/template")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class TemplateResource {

    // In-memory database simulation
    // In production, use a service with real database
    private static List<TemplateEntity> items = new ArrayList<>();
    private static Long nextId = 1L;
    
    static {
        // Example data
        items.add(new TemplateEntity(1L, "Item 1", "Description de l'item 1"));
        items.add(new TemplateEntity(2L, "Item 2", "Description de l'item 2"));
        nextId = 3L;
    }

    /**
     * 📋 GET /template - Liste tous les éléments
     * 
     * @return Liste de tous les éléments
     */
    @GET
    public List<TemplateEntity> listAll() {
        return items;
    }

    /**
     * 🔍 GET /template/{id} - Récupère un élément par ID
     * 
     * @param id L'ID de l'élément à récupérer
     * @return L'élément trouvé
     * @throws NotFoundException Si l'élément n'existe pas
     */
    @GET
    @Path("/{id}")
    public TemplateEntity getById(@PathParam("id") Long id) {
        return findById(id)
            .orElseThrow(() -> new NotFoundException("Élément avec ID " + id + " introuvable"));
    }

    /**
     * ➕ POST /template - Crée un nouvel élément
     * 
     * @param entity L'élément à créer (sans ID)
     * @return Réponse avec l'élément créé et status 201
     */
    @POST
    public Response create(TemplateEntity entity) {
        // Basic validation
        if (entity.name == null || entity.name.trim().isEmpty()) {
            return Response.status(400)
                .entity(new ErrorResponse("Le nom est obligatoire"))
                .build();
        }

        // Assign new ID
        entity.id = nextId++;
        items.add(entity);

        return Response.status(201)
            .entity(entity)
            .build();
    }

    /**
     * ✏️ PUT /template/{id} - Met à jour un élément existant
     * 
     * @param id L'ID de l'élément à modifier
     * @param updatedEntity Les nouvelles données
     * @return L'élément mis à jour
     * @throws NotFoundException Si l'élément n'existe pas
     */
    @PUT
    @Path("/{id}")
    public TemplateEntity update(@PathParam("id") Long id, TemplateEntity updatedEntity) {
        TemplateEntity existing = findById(id)
            .orElseThrow(() -> new NotFoundException("Élément avec ID " + id + " introuvable"));

        // Update fields
        if (updatedEntity.name != null) {
            existing.name = updatedEntity.name;
        }
        if (updatedEntity.description != null) {
            existing.description = updatedEntity.description;
        }

        return existing;
    }

    /**
     * 🗑️ DELETE /template/{id} - Supprime un élément
     * 
     * @param id L'ID de l'élément à supprimer
     * @return Réponse vide avec status 204
     */
    @DELETE
    @Path("/{id}")
    public Response delete(@PathParam("id") Long id) {
        boolean removed = items.removeIf(item -> item.id.equals(id));
        
        if (!removed) {
            throw new NotFoundException("Élément avec ID " + id + " introuvable");
        }

        return Response.noContent().build();
    }

    /**
     * 🔍 GET /template/search?name=xxx - Recherche par nom
     * 
     * @param name Le nom à rechercher (partiel)
     * @return Liste des éléments correspondants
     */
    @GET
    @Path("/search")
    public List<TemplateEntity> searchByName(@QueryParam("name") String name) {
        if (name == null || name.trim().isEmpty()) {
            return items;
        }

        return items.stream()
            .filter(item -> item.name.toLowerCase().contains(name.toLowerCase()))
            .toList();
    }

    /**
     * 📊 GET /template/count - Compte le nombre d'éléments
     * 
     * @return Objet avec le nombre total
     */
    @GET
    @Path("/count")
    public CountResponse count() {
        return new CountResponse(items.size());
    }

    // ========================================================================
    // PRIVATE UTILITY METHODS
    // ========================================================================

    private Optional<TemplateEntity> findById(Long id) {
        return items.stream()
            .filter(item -> item.id.equals(id))
            .findFirst();
    }

    // ========================================================================
    // INNER CLASSES - ENTITIES AND RESPONSES
    // ========================================================================
    // 💡 In production, create separate files in the model/ package

    /**
     * 📦 Entité principale du template
     */
    public static class TemplateEntity {
        public Long id;
        public String name;
        public String description;

        // Constructors
        public TemplateEntity() {}

        public TemplateEntity(Long id, String name, String description) {
            this.id = id;
            this.name = name;
            this.description = description;
        }

        @Override
        public String toString() {
            return "TemplateEntity{id=" + id + ", name='" + name + "', description='" + description + "'}";
        }
    }

    /**
     * 🚨 Réponse d'erreur standardisée
     */
    public static class ErrorResponse {
        public String error;
        public long timestamp;

        public ErrorResponse(String error) {
            this.error = error;
            this.timestamp = System.currentTimeMillis();
        }
    }

    /**
     * 📊 Réponse pour le comptage
     */
    public static class CountResponse {
        public int count;

        public CountResponse(int count) {
            this.count = count;
        }
    }
}

/*
 * ============================================================================
 * 🧪 EXEMPLES D'UTILISATION (après déploiement)
 * ============================================================================
 * 
 * # URL de base (remplacez par votre Lambda URL)
 * LAMBDA_URL="https://xxx.lambda-url.region.on.aws"
 * 
 * # Liste tous les éléments
 * curl $LAMBDA_URL/template
 * 
 * # Récupère un élément par ID
 * curl $LAMBDA_URL/template/1
 * 
 * # Crée un nouvel élément
 * curl -X POST $LAMBDA_URL/template \
 *   -H "Content-Type: application/json" \
 *   -d '{"name":"Nouvel item","description":"Description du nouvel item"}'
 * 
 * # Met à jour un élément
 * curl -X PUT $LAMBDA_URL/template/1 \
 *   -H "Content-Type: application/json" \
 *   -d '{"name":"Item modifié","description":"Nouvelle description"}'
 * 
 * # Supprime un élément
 * curl -X DELETE $LAMBDA_URL/template/1
 * 
 * # Recherche par nom
 * curl $LAMBDA_URL/template/search?name=item
 * 
 * # Compte les éléments
 * curl $LAMBDA_URL/template/count
 * 
 * ============================================================================
 * 📝 NOTES POUR L'IMPLÉMENTATION
 * ============================================================================
 * 
 * 1. 🗃️ BASE DE DONNÉES
 *    Remplacez la liste en mémoire par un vrai service de persistance :
 *    - PostgreSQL avec Hibernate ORM Panache
 *    - DynamoDB avec AWS SDK
 *    - MongoDB avec Panache
 * 
 * 2. ✅ VALIDATION
 *    Ajoutez des validations robustes :
 *    - Bean Validation (@NotNull, @Size, etc.)
 *    - Validation métier dans les services
 * 
 * 3. 🔐 SÉCURITÉ
 *    Implémentez l'authentification/autorisation :
 *    - JWT avec Quarkus Security
 *    - AWS Cognito
 *    - Validation des rôles
 * 
 * 4. 🚨 GESTION D'ERREURS
 *    Créez un gestionnaire d'exceptions global :
 *    - ExceptionMapper pour standardiser les erreurs
 *    - Logs détaillés pour le debug
 * 
 * 5. 📊 OBSERVABILITÉ
 *    Ajoutez monitoring et métriques :
 *    - Health checks
 *    - Métriques CloudWatch
 *    - Tracing distribué
 * 
 * ============================================================================
 */