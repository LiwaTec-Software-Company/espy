  //
  //  EditView.swift
  //  Espy
  //
  //  Created by Willie Johnson on 9/1/21.
  //

import SwiftUI

@available(iOS 15.0, *)
struct EditView: View {
  @Environment(\.presentationMode) var presentationMode
  @ObservedObject var viewModel: EditViewModel

  var body: some View {
    VStack(alignment: .center, spacing: 4.0, content: {
        // Header
      HStack {
        TrashButton(onPress: {
          if (!viewModel.isNew) {
            viewModel.delete(viewModel.selectedEntry)
            presentationMode.wrappedValue.dismiss()
          }
        })
        Spacer()
        Text(viewModel.selectedEntry.createdAt.displayDate()).padding(5).font(.title3).foregroundColor(viewModel.isNew ? .green : .primary)
        Spacer()
        EditModeButton()
      }.padding()

      ZStack(alignment: .bottomLeading) {
        QuickTextEditor(text: $viewModel.fullText, activeFont: $viewModel.activeFont, placeholder: "# Untitled") { value in
          viewModel.onEditorChanged()
        } onScroll: { scrollView in
          DispatchQueue.main.async {
            if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height {
              viewModel.isAtBottom = true
              print(viewModel.isAtBottom)
            } else if scrollView.contentOffset.y <= scrollView.contentSize.height - scrollView.frame.size.height {
              viewModel.isAtBottom = false
            }
          }
        }
        .cornerRadius(10)
        .padding(10)
          // Footer
        VStack(alignment: .center) {
          Text(viewModel.selectedEntry.id.uuidString).font(.subheadline).foregroundColor(viewModel.isNew ? .green : .gray).lineLimit(1)
          HStack(alignment: .center) {
            ImportButton(onPress: {
              print("eh")
            })
            VStack(alignment: .center, spacing: 1) {
              Text(viewModel.currentDate.formattedStringDate()).font(.caption).foregroundColor((viewModel.isTextUpdated || viewModel.isNew) ? .green : .gray)
              Button(action: {
                viewModel.save()
                presentationMode.wrappedValue.dismiss()
              }, label: {
                Image(systemName: "chevron.compact.down")
                  .font(.system(size: 44.0, weight: .bold)).foregroundColor((viewModel.isTextUpdated || viewModel.isNew) ? .green : .accentColor)
              })
              .padding(10)
            }
            .frame(maxWidth: .infinity)
            ExportButton()
          }
        }
        .padding(10)
        .background(Color.black.opacity(viewModel.isAtBottom ? 0 : 0.5))
        .cornerRadius(10)
        .padding(10)

      }
    })
      .onAppear(perform: {
     
      })
  }
}

//@available(iOS 15.0, *)
//struct EditView_Previews: PreviewProvider {
//  static var previews: some View {
//    EditView()
//  }
//}
