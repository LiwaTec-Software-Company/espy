  //
  //  ContentView.swift
  //  Espy
  //
  //  Created by Willie Johnson on 8/29/21.
  //

import SwiftUI

struct MainView: View {
  @ObservedObject var viewModel: MainViewModel

  var body: some View {
    NavigationView {
      ScrollView {
        VStack {
          ForEach(viewModel.entryMap.sorted(by: {$0.value > $1.value}), id: \.key) { id, entry in
            EntryRow(entry: entry, action: {
              if !viewModel.isMultiSelectOn {
                viewModel.open(entry)
              }
            }, secondaryAction: {
              viewModel.isMultiSelectOn.toggle()
            }, thirdAction: {
                //              viewModel.isEditModeOn.toggle()
            })

          }
          .onDelete(perform: onDelete)
        }
        .onAppear {
          viewModel.reloadEntryMap()
        }
      }

      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          TrashButton(onPress: {
            if viewModel.isMultiSelectOn {
              viewModel.isMultiSelectOn.toggle()
            }
          })
        }

        ToolbarItem(placement: .principal) {
          BlockModeButton(onPress: {
            viewModel.toggleBlockMode()
          })
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          EditModeButton()
        }

        ToolbarItemGroup(placement: .bottomBar) {
          ImportButton(onPress: {
            viewModel.openDocSheet()
          })
          Spacer()
          HStack {
            Button(action: {
              viewModel.open(Entry(), isNew: true)
            }) {
              if viewModel.isMultipleSelected { ZStack { Image(systemName: "chevron.compact.up")
                    .font(.system(size: 44))
                  Image(systemName: "chevron.compact.up")
                    .font(.system(size: 44)).offset(x: 0, y: 10)
                }
              } else if viewModel.isAnythingSelected {
                Image(systemName: "chevron.compact.up")
                  .font(.system(size: 44, weight: .bold))
              } else {
                Image(systemName: "chevron.compact.up")
                  .font(.system(size: 44, weight: .bold)).foregroundColor(.green)
              }
            }
            Text("")
          }
          Spacer()
          ExportButton()
        }
      }
    }
  }

  func onDelete(at offsets: IndexSet) {
      // preserve all ids to be deleted to avoid indices confusing
    let entriesToDelete = offsets.map { Array(viewModel.entryMap.values)[$0] }
    viewModel.delete(entriesToDelete)
  }

  func deleteAllSelectedEntries() {
    viewModel.deleteAllSelected()
  }

  func selectAllRows() {
    viewModel.selectAll()
  }

  func unselectAllRows() {
    viewModel.selectionMap.removeAll()
  }
}


