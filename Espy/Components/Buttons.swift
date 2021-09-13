//
//  Buttons.swift
//  Buttons
//
//  Created by Willie Johnson on 9/10/21.
//

import SwiftUI

struct ButtonStyle {
  static let normalFontSize: CGFloat = 18
  static let disabledFontSize: CGFloat = 15
}

struct TrashButton: View {
  @EnvironmentObject var viewModel: MainViewModel

  var onPress: () -> Void

  var body: some View {
    HStack{
      Button(action: {
        onPress()
      }, label: {
        Image(systemName: viewModel.isAnythingSelected ? "trash.fill": "trash")
          .font(Font.system(size: (viewModel.isAnythingSelected || viewModel.isMultiSelectOn) ? ButtonStyle.normalFontSize : ButtonStyle.disabledFontSize))
          .foregroundColor(viewModel.isAnythingSelected ? .red : .gray)
        Text("")
      }).disabled(!(viewModel.isMultiSelectOn || viewModel.isAnythingSelected))
    }
  }
}

struct EditModeButton: View {
  @EnvironmentObject var viewModel: MainViewModel

  var body: some View {
    HStack{
      Button(action: {
        viewModel.isEditModeOn.toggle()
      }, label: {
        Image(systemName: viewModel.isEditModeOn ? "doc.richtext" : "doc.richtext.fill")
          .font(Font.system(size: ButtonStyle.normalFontSize))
          .foregroundColor(.accentColor)
        Text("")
      })
    }
  }
}

struct BlockModeButton: View {
  @EnvironmentObject var viewModel: MainViewModel

  var onPress: () -> Void

  var body: some View {
    HStack{
      Button(action: {
        onPress()
      }, label: {
        Image(systemName: (viewModel.isEverythingSelected && viewModel.isMultiSelectOn) ? "xmark.circle.fill" : viewModel.isMultiSelectOn ? "rectangle.grid.1x2.fill" : "rectangle.grid.1x2")
          .font(Font.system(size: ButtonStyle.normalFontSize))
          .foregroundColor(.accentColor)
        Text("")
      })
    }
  }
}

struct ExportButton: View {
  @EnvironmentObject var viewModel: MainViewModel

  var body: some View {
    NavigationLink(destination: ExportView()) {
      Image(systemName: viewModel.isMultipleSelected ? "rectangle.portrait.and.arrow.right.fill" : "rectangle.portrait.and.arrow.right")
    }
  }
}

struct ImportButton: View {
  @EnvironmentObject var viewModel: MainViewModel
  var onPress: () -> Void

  var body: some View {
    Button(action: {
      onPress()
    }, label: {
      Image(systemName: viewModel.isMultipleSelected ? "square.and.arrow.down.on.square.fill" : viewModel.isAnythingSelected ? "square.and.arrow.down.fill" : "folder.badge.gearshape")
    })
  }
}


struct Buttons: View {
    var body: some View {
      VStack {
        Text("BUTTONS")
        TrashButton {
          print("trash")
        }
        EditModeButton()
        BlockModeButton {
          print("block mode")
        }
      }
    }
}

struct Buttons_Previews: PreviewProvider {
    static var previews: some View {
        Buttons()
    }
}
