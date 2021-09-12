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
  @EnvironmentObject var contentManager: ContentManager

  var onPress: () -> Void

  var body: some View {
    HStack{
      Button(action: {
        onPress()
      }, label: {
        Image(systemName: contentManager.isAnythingSelected ? "trash.fill": "trash")
          .font(Font.system(size: (contentManager.isAnythingSelected || contentManager.isMultiSelectOn) ? ButtonStyle.normalFontSize : ButtonStyle.disabledFontSize))
          .foregroundColor(contentManager.isAnythingSelected ? .red : .gray)
        Text("")
      }).disabled(!(contentManager.isMultiSelectOn || contentManager.isAnythingSelected))
    }
  }
}

struct EditModeButton: View {
  @EnvironmentObject var contentManager: ContentManager

  var body: some View {
    HStack{
      Button(action: {
        contentManager.isEditModeOn.toggle()
      }, label: {
        Image(systemName: contentManager.isEditModeOn ? "doc.richtext" : "doc.richtext.fill")
          .font(Font.system(size: ButtonStyle.normalFontSize))
          .foregroundColor(.accentColor)
        Text("")
      })
    }
  }
}

struct BlockModeButton: View {
  @EnvironmentObject var contentManager: ContentManager

  var onPress: () -> Void

  var body: some View {
    HStack{
      Button(action: {
        onPress()
      }, label: {
        Image(systemName: (contentManager.isEverythingSelected && contentManager.isMultiSelectOn) ? "xmark.circle.fill" : contentManager.isMultiSelectOn ? "rectangle.grid.1x2.fill" : "rectangle.grid.1x2")
          .font(Font.system(size: ButtonStyle.normalFontSize))
          .foregroundColor(.accentColor)
        Text("")
      })
    }
  }
}

struct ExportButton: View {
  @EnvironmentObject var contentManager: ContentManager

  var body: some View {
    NavigationLink(destination: ExportView()) {
      Image(systemName: contentManager.isMultipleSelected ? "rectangle.portrait.and.arrow.right.fill" : "rectangle.portrait.and.arrow.right")
    }
  }
}

struct ImportButton: View {
  @EnvironmentObject var contentManager: ContentManager
  var onPress: () -> Void

  var body: some View {
    Button(action: {
      onPress()
    }, label: {
      Image(systemName: contentManager.isMultipleSelected ? "square.and.arrow.down.on.square.fill" : contentManager.isAnythingSelected ? "square.and.arrow.down.fill" : "folder.badge.gearshape")
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
