import SwiftUI

struct CategoryCard: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        VStack {
            // Category Icon/Image
            Image(systemName: CategoryIconMap.iconName(for: category.name))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(isSelected ? .white : .black)
                .padding(12)
                .background(isSelected ? Color.green : Color.gray.opacity(0.1))
                .clipShape(Circle())
            
            // Category Name
            Text(category.name)
                .font(.caption)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .green : .black)
                .lineLimit(1)
        }
        .frame(width: 80, height: 80)
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    HStack {
        CategoryCard(
            category: Category.sampleCategories[0],
            isSelected: true,
            action: {}
        )
        
        CategoryCard(
            category: Category.sampleCategories[1],
            isSelected: false,
            action: {}
        )
    }
    .padding()
} 