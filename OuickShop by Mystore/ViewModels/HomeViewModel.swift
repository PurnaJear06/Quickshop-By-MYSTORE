import Foundation
import Combine

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
    
    init() {
        // Load mock data (in a real app, this would fetch from Firebase)
        loadData()
        
        // Setup search functionality
        setupSearchPublisher()
    }
    
    private func loadData() {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Load products and categories from mock data
            self.products = Product.sampleProducts
            self.categories = Category.sampleCategories
            self.featuredProducts = self.products.filter { $0.isFeatured }
            self.filteredProducts = self.products
            
            // Set recent products (in a real app, this would be based on user's order history)
            if !self.products.isEmpty {
                self.recentProducts = Array(self.products.prefix(5))
            }
            
            self.isLoading = false
        }
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
    
    // Method to simulate refreshing data
    func refreshData() {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // Reload data (in a real app, this would fetch fresh data from Firebase)
            self.loadData()
        }
    }
} 