import Foundation
import Combine
import FirebaseFirestore

class HomeViewModel: ObservableObject {
    // Published properties for UI updates
    @Published var products: [Product] = []
    @Published var categories: [Category] = []
    @Published var featuredProducts: [Product] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: String? = nil
    @Published var isLoading: Bool = false
    
    // Recent/Previously bought products
    @Published var recentProducts: [Product] = []
    
    // Filtered products based on search text and selected category
    @Published var filteredProducts: [Product] = []
    
    // Search results
    @Published var searchResults: [Product] = []
    
    // Computed property to check if the Summer view should be shown
    var isSummerSelected: Bool {
        return selectedCategory?.lowercased() == "summer"
    }
    
    // Cancellables for Combine
    private var cancellables = Set<AnyCancellable>()
    
    // Firestore reference
    private let db = Firestore.firestore()
    private var productsListener: ListenerRegistration?
    
    init() {
        print("🏠 HomeViewModel initialized - starting data load")
        
        // Load real products from Firebase Firestore
        loadProductsFromFirestore()
        
        // Load categories
        loadCategories()
        
        // Setup search functionality
        setupSearchPublisher()
    }
    
    deinit {
        // Remove Firestore listener when ViewModel is deallocated
        productsListener?.remove()
    }
    
    // Load products from Firestore with real-time updates
    private func loadProductsFromFirestore() {
        isLoading = true
        print("📦 Loading products from Firestore...")
        
        // Set up real-time listener for products collection
        productsListener = db.collection("products")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ Error loading products: \(error.localizedDescription)")
                        self.isLoading = false
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        print("⚠️ No products found in Firestore")
                        self.isLoading = false
                        return
                    }
                    
                    // Parse products from Firestore
                    self.products = documents.compactMap { doc -> Product? in
                        let data = doc.data()
                        
                        guard let name = data["name"] as? String else { return nil }
                        
                        let category = data["category"] as? String ?? "Other"
                        
                        return Product(
                            id: doc.documentID,
                            name: name,
                            description: data["description"] as? String ?? "",
                            price: data["price"] as? Double ?? 0.0,
                            mrp: data["mrp"] as? Double,
                            imageURL: data["imageURL"] as? String ?? "",
                            category: category,
                            isAvailable: data["isAvailable"] as? Bool ?? true,
                            isFeatured: data["isFeatured"] as? Bool ?? false,
                            weight: data["weight"] as? String ?? "1pc",
                            stockQuantity: data["stockQuantity"] as? Int ?? 0,
                            gst: data["gst"] as? Double ?? 5.0  // Default to 5% if not specified
                        )
                    }
                    
                    print("✅ Loaded \(self.products.count) products from Firestore")
                    
                    // Log unique categories for debugging
                    let uniqueCategories = Set(self.products.map { $0.category })
                    print("📂 Product categories in Firestore: \(uniqueCategories.sorted())")
                    
                    // Update featured products
                    self.featuredProducts = self.products.filter { $0.isFeatured }
                    self.filteredProducts = self.products
                    
                    // Set recent products (first 5 for now)
                    if !self.products.isEmpty {
                        self.recentProducts = Array(self.products.prefix(5))
                    }
                    
                    self.isLoading = false
                }
            }
    }
    
    // Load categories
    private func loadCategories() {
        // For now, use sample categories
        // In future, you can load these from Firestore as well
        self.categories = Category.sampleCategories
    }
    
    private func setupSearchPublisher() {
        // Combine publisher to handle search text changes
        $searchText
            .combineLatest($selectedCategory)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] (searchText, selectedCategory) in
                guard let self = self else { return }
                
                self.filterProducts(searchText: searchText, category: selectedCategory)
            }
            .store(in: &cancellables)
    }
    
    private func filterProducts(searchText: String, category: String?) {
        // Start with all products
        var filtered = self.products
        
        // Filter by category if selected
        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filter by search text if not empty
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Update filtered products
        self.filteredProducts = filtered
    }
    
    // Select a category
    func selectCategory(_ category: String?) {
        selectedCategory = category
    }
    
    // Method to refresh products from Firestore
    func refreshData() {
        print("🔄 Refreshing products...")
        // Real-time listener will automatically update products
        // Just show loading indicator briefly
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
        }
    }
} 