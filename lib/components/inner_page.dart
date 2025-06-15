import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:hive/hive.dart';
import 'package:memno/components/inner_page_fun.dart';
import 'package:memno/components/show_toast.dart';
import 'package:memno/database/preview_data.dart';
import 'package:memno/functionality/code_gen.dart';
import 'package:memno/functionality/preview_map.dart';
import 'package:memno/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:linkfy_text/linkfy_text.dart';

/// Main page widget for displaying and editing a list of links and a title.
class InnerPage extends StatefulWidget {
  final int code;
  const InnerPage({super.key, required this.code});

  @override
  State<InnerPage> createState() => _InnerPageState();
}

class _InnerPageState extends State<InnerPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _linkController = TextEditingController();
  final FocusNode _fabFocus = FocusNode();

  Map<String, PreviewData> fetched = {};

  int _isEditMode = 0; // 0: add, 1: edit, 2: edit title, 3: delete
  int _editIndex = -1; // Index of the item being edited/deleted

  @override
  Widget build(BuildContext context) {
    final colors = Provider.of<AppColors>(context);
    final codeProvider = Provider.of<CodeGen>(context);

    return Hero(
      tag: 'fab_to_page',
      transitionOnUserGestures: true,
      child: Material(
        type: MaterialType.transparency,
        child: Scaffold(
          backgroundColor: colors.bgClr,
          appBar: AppBar(
            backgroundColor: colors.bgClr,
            foregroundColor: colors.fgClr,
            surfaceTintColor: colors.bgClr,
          ),
          body: Consumer2<CodeGen, PreviewMap>(
            builder: (context, codeProvider, previewMap, child) {
              final links = codeProvider.getLinksForCode(widget.code);
              String head = codeProvider.getHeadForCode(widget.code);

              // If there are no links, show an empty state
              return links.isEmpty
                  ? ListView(
                      children: [
                        innerPageTopBar(context, head),
                        const SizedBox(height: 50),
                        Center(
                          child: Text(
                            "It's so empty here...",
                            style: TextStyle(
                                color: colors.textClr, fontFamily: 'Product'),
                          ),
                        ),
                      ],
                    )
                  // Otherwise, show the list of links with previews
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 160),
                      itemCount: links.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Top bar with title
                          return innerPageTopBar(context, head);
                        } else {
                          return Stack(
                            children: [
                              // Main link preview container
                              Container(
                                key: ValueKey(links[index - 1]),
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.fromLTRB(2, 4, 2, 4),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(50),
                                  ),
                                  color: colors.box,
                                ),
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(50),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 70),
                                      // Show link preview if valid, otherwise just text
                                      child: AnyLinkPreview.isValidLink(
                                              //Check if the link is valid or not
                                              links[index - 1].split(' ').first)
                                          ? LinkPreview(
                                              requestTimeout:
                                                  const Duration(seconds: 10),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width +
                                                  50,
                                              enableAnimation: true,
                                              openOnPreviewImageTap: true,
                                              openOnPreviewTitleTap: true,
                                              header: links[index - 1]
                                                          .split(' ')
                                                          .length >
                                                      1
                                                  ? links[index - 1]
                                                      .split(' ')
                                                      .skip(1)
                                                      .join(' ')
                                                      .trim()
                                                  : null,
                                              headerStyle: TextStyle(
                                                  color: colors.textClr,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 32,
                                                  fontFamily: 'Product'),
                                              textWidget: LinkifyText(
                                                links[index - 1]
                                                    .split(' ')
                                                    .first,
                                                linkStyle: const TextStyle(
                                                  color: Colors.blue,
                                                  fontFamily: 'Product',
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                onTap: (p0) {
                                                  launchUrl(Uri.parse(
                                                      links[index - 1]));
                                                },
                                                maxLines: 2,
                                              ),
                                              textStyle: const TextStyle(
                                                  fontFamily: 'Product',
                                                  fontSize: 12),
                                              metadataTitleStyle: TextStyle(
                                                  color: colors.textClr,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                  fontFamily: 'Product'),
                                              metadataTextStyle: TextStyle(
                                                  color: colors.textClr,
                                                  fontSize: 14,
                                                  fontFamily: 'Product'),
                                              onLinkPressed: (url) {
                                                launchUrl(Uri.parse(
                                                    links[index - 1]));
                                              },
                                              onPreviewDataFetched:
                                                  (data) async {
                                                // setState(() {
                                                //   previewMap.storePreview(
                                                //       links[index - 1], data);
                                                // });

                                                // Save the preview data
                                                await previewMap.savePreview(
                                                    links[index - 1], data);

                                                // final previewsBox =
                                                //     await Hive.openBox<PreviewDataModel>(
                                                //         'previewsBox');
                                                // final previewDataModel = PreviewDataModel(
                                                //   title: data.title,
                                                //   description: data.description,
                                                //   image: data.image?.url,
                                                //   imageHeight: data.image?.height,
                                                //   imageWidth: data.image?.width,
                                                //   link: data.link,
                                                // );
                                                // await previewsBox.put(
                                                //     links[index - 1],
                                                //     previewDataModel);
                                              },
                                              previewData:
                                                  previewMap.loadPreview(
                                                      links[index - 1]),
                                              text: links[index - 1],
                                            )
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      36, 26, 26, 26),
                                              child: Text(
                                                links[index - 1],
                                                style: TextStyle(
                                                  color: colors.textClr,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Product',
                                                  fontSize: 24,
                                                ),
                                              ),
                                            ),
                                    )),
                              ),
                              // Button bar (copy, edit, delete)
                              Positioned(
                                top: 10,
                                right: 20,
                                child: SizedBox(
                                  width: 200,
                                  height: 80,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Copy Button
                                        InnerPageButton(
                                          onPressed: () {
                                            showToastMsg(
                                                context, "Item copied!");
                                            Clipboard.setData(
                                              ClipboardData(
                                                  text: links[index - 1]),
                                            );
                                          },
                                          icon: Icons.copy_rounded,
                                        ),
                                        const Spacer(),
                                        // Edit Button
                                        InnerPageButton(
                                          icon: Icons.mode_edit_outline_rounded,
                                          onPressed: () {
                                            setState(() {
                                              _isEditMode = 1;
                                              _editIndex = index - 1;
                                              _linkController.text =
                                                  links[index - 1];
                                            });
                                            FocusScope.of(context)
                                                .requestFocus(_fabFocus);
                                          },
                                        ),
                                        const Spacer(),
                                        // Delete Button
                                        InnerPageButton(
                                          icon: Icons.delete_rounded,
                                          onPressed: () {
                                            setState(() {
                                              _isEditMode = 3;
                                              _editIndex = index - 1;
                                              _linkController.text =
                                                  "Do you want to delete entry no.$index ? This is irreversible.";
                                            });
                                            FocusScope.of(context)
                                                .requestFocus(_fabFocus);
                                          },
                                        ),
                                      ]),
                                ),
                              ),
                              // Index badge
                              Positioned(
                                  top: 22,
                                  left: 22,
                                  child: Container(
                                    height: 58,
                                    width: 78,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(50),
                                      ),
                                      color: Colors.black,
                                    ),
                                    child: Center(
                                      child: Text(
                                        index.toString(),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontFamily: 'Product'),
                                      ),
                                    ),
                                  ))
                            ],
                          );
                        }
                      });
            },
          ),
          // Floating action button for adding/editing/deleting entries
          floatingActionButton: CustomInnerFAB(
            onConfirm: () {
              if (_linkController.text.isNotEmpty) {
                if (_isEditMode == 1) {
                  // Edit existing link
                  codeProvider.editLink(
                      widget.code, _editIndex, _linkController.text);
                  showToastMsg(context, "Entry edited!");
                } else if (_isEditMode == 2) {
                  // Edit title
                  codeProvider.addHead(widget.code, _linkController.text);
                  showToastMsg(context, "New title added!");
                } else if (_isEditMode == 3) {
                  // Delete link
                  codeProvider.deleteLink(widget.code, _editIndex);
                  showToastMsg(context, "Entry deleted!");
                } else {
                  // Add new link
                  codeProvider.addLink(widget.code, _linkController.text);
                  showToastMsg(context, "New entry added!");
                }
              }
              setState(() {
                _isEditMode = 0;
                _editIndex = -1;
              });
              _linkController.clear();
              FocusScope.of(context).unfocus();
            },
            onCancel: () {
              if (_linkController.text.isNotEmpty) {
                showToastMsg(context, "Action cancelled!");
              }
              setState(() {
                _isEditMode = 0;
                _editIndex = -1;
              });
              _linkController.clear();
              FocusScope.of(context).unfocus();
            },
            controller: _linkController,
            isEditMode: _isEditMode,
            fabFocus: _fabFocus,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }

  /// Top bar widget showing the title and edit button
  Widget innerPageTopBar(BuildContext context, String head) {
    final colors = Provider.of<AppColors>(context);
    return Container(
      alignment: Alignment.centerLeft,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.fromLTRB(2, 0, 2, 4),
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: colors.accnt,
      ),
      child: Stack(
        children: [
          // Title text (truncated if too long)
          Positioned(
            top: 42,
            left: 26,
            child: Text(head.length > 12 ? "${head.substring(0, 12)}..." : head,
                style: const TextStyle(
                    fontFamily: 'Product',
                    fontWeight: FontWeight.w700,
                    fontSize: 48)),
          ),
          // Edit title button
          Positioned(
              bottom: 10,
              right: 10,
              child: IconButton(
                  tooltip: "Edit title",
                  onPressed: () {
                    setState(() {
                      _isEditMode = 2;
                      _linkController.text = head;
                    });
                    FocusScope.of(context).requestFocus(_fabFocus);
                  },
                  icon: const Icon(Icons.mode_edit_outline_outlined)))
        ],
      ),
    );
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }
}

/// Custom floating action bar for adding/editing/deleting links or title.
class CustomInnerFAB extends StatelessWidget {
  const CustomInnerFAB({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    required this.controller,
    required this.isEditMode,
    required this.fabFocus,
  });
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final TextEditingController controller;
  final int isEditMode;
  final FocusNode fabFocus;

  @override
  Widget build(BuildContext context) {
    final colors = Provider.of<AppColors>(context);

    return Container(
      padding: const EdgeInsets.all(8),
      width: MediaQuery.of(context).size.width - 25,
      height: 130,
      decoration: BoxDecoration(
          color: colors.bgClr,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: colors.fgClr, width: 1)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Text field for link or title input
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(42), color: colors.box),
              child: TextField(
                focusNode: fabFocus,
                controller: controller,
                minLines: null,
                maxLines: null,
                expands: true,
                style: TextStyle(
                  color: colors.fgClr,
                  fontFamily: 'Product',
                ),
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          // Confirm and cancel buttons
          Expanded(
            flex: 1,
            child: Column(
              children: [
                const Spacer(),
                IconButton(
                    onPressed: onConfirm,
                    icon: Icon(
                        isEditMode == 0
                            ? Icons.add_rounded
                            : Icons.check_rounded,
                        color: Colors.green)),
                const Spacer(),
                IconButton(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close_rounded, color: Colors.red)),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
