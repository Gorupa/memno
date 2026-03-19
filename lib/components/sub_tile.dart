import 'package:flutter/material.dart';
import 'package:memno/components/inner_page.dart';
import 'package:memno/components/show_toast.dart';
import 'package:memno/functionality/code_gen.dart';
import 'package:memno/theme/app_colors.dart';
import 'package:provider/provider.dart';

import 'package:memno/components/inner_page_fun.dart';

class SubTile extends StatelessWidget {
  final int code;
  final String date;
  final bool isLiked;

  const SubTile({
    super.key,
    required this.code,
    required this.date,
    required this.isLiked,
  });

  @override
  Widget build(BuildContext context) {
    int length = context.read<CodeGen>().getLinkListLength(code);
    double radius = 50;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 4),
      child: SubTileStack(
        code: code,
        date: date,
        isLiked: isLiked,
        length: length,
        radius: radius,
      ),
    );
  }
}

class SubTileStack extends StatefulWidget {
  const SubTileStack({
    super.key,
    required this.code,
    required this.date,
    required this.isLiked,
    required this.length,
    required this.radius,
  });

  final int code;
  final String date;
  final bool isLiked;
  final int length;
  final double radius;

  @override
  State<SubTileStack> createState() => _SubTileStackState();
}

class _SubTileStackState extends State<SubTileStack> {
  bool showDltConfirm = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //Background Container
        BgContainer(radius: widget.radius),
        if (!showDltConfirm) ...[
          //Code Text
          CodeText(code: widget.code),
          //Head Text
          HeadText(code: widget.code),
          //Length indicator
          LengthIndicator(
            radius: widget.radius,
            length: widget.length,
            code: widget.code,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InnerPage(code: widget.code),
                ),
              );
            },
          ),
          // Action Bar (Date, Like, Delete)
          Positioned(
            top: 12,
            left: 14,
            right: 14,
            child: SizedBox(
              height: 65,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  spacing: 8,
                  children: [
                    // Date Display (Unified Style)
                    InnerPageButton(
                      icon: Icons.calendar_month_outlined,
                      label: getFormattedDate(DateTime.parse(widget.date)),
                      onPressed: () {},
                    ),
                    // Like Button
                    InnerPageButton(
                      key: ValueKey(widget.code),
                      icon: widget.isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      label: widget.isLiked ? "Liked" : "Like",
                      onPressed: () {
                        context.read<CodeGen>().toggleLike(widget.code);
                        if (widget.isLiked) {
                          showToastMsg(
                            context,
                            "#${widget.code} removed from favorites",
                          );
                        } else {
                          showToastMsg(
                            context,
                            "#${widget.code} added to favorites",
                          );
                        }
                      },
                    ),
                    // Delete Button
                    InnerPageButton(
                      icon: Icons.delete_outline_rounded,
                      label: "Delete",
                      onPressed: () {
                        setState(() {
                          showDltConfirm = true;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ] else ...[
          ShowDltPrompt(
            length: widget.length,
            radius: widget.radius,
            onProceed: () {
              context.read<CodeGen>().clearList(widget.code);
              setState(() {
                showDltConfirm = false;
              });
              showToastMsg(context, "Code #${widget.code} deleted");
            },
            onCancel: () {
              setState(() {
                showDltConfirm = false;
              });
              showToastMsg(context, "Action cancelled");
            },
          ),
        ],
      ],
    );
  }
}

class ShowDltPrompt extends StatelessWidget {
  const ShowDltPrompt({
    super.key,
    required this.length,
    required this.radius,
    required this.onProceed,
    required this.onCancel,
  });

  final int length;
  final double radius;
  final VoidCallback onProceed;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = Provider.of<AppColors>(context);
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "You sure you want to delete?\nCurrently contains $length items",
            style: TextStyle(
              color: colors.textClr,
              fontSize: 16,
              fontFamily: 'Product',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ContainerButton(onTap: onCancel, radius: radius, text: "No"),
              const SizedBox(width: 20),
              ContainerButton(onTap: onProceed, radius: radius, text: "Yes"),
            ],
          ),
        ],
      ),
    );
  }
}

class ContainerButton extends StatelessWidget {
  const ContainerButton({
    super.key,
    required this.onTap,
    required this.radius,
    required this.text,
  });

  final VoidCallback onTap;
  final double radius;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Provider.of<AppColors>(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.pill,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textClr, fontFamily: 'Product'),
        ),
      ),
    );
  }
}

class BgContainer extends StatelessWidget {
  const BgContainer({super.key, required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = Provider.of<AppColors>(context);
    return Container(
      height: 250,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: colors.box,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class CodeText extends StatelessWidget {
  const CodeText({super.key, required this.code});

  final int code;
  @override
  Widget build(BuildContext context) {
    final colors = Provider.of<AppColors>(context);
    return Positioned(
      bottom: 16,
      left: 26,
      child: SelectableText(
        "#$code",
        style: TextStyle(
          color: colors.textClr,
          fontSize: 26,
          fontWeight: FontWeight.w400,
          fontFamily: 'Product',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class HeadText extends StatelessWidget {
  const HeadText({super.key, required this.code});

  final int code;

  @override
  Widget build(BuildContext context) {
    final colors = Provider.of<AppColors>(context);
    String head = Provider.of<CodeGen>(context).getHeadForCode(code);
    return Positioned(
      bottom: 96,
      left: 26,
      right: 160,
      child: Text(
        head,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: colors.textClr,
          fontSize: 36,
          fontWeight: FontWeight.w500,
          fontFamily: 'Product',
        ),
      ),
    );
  }
}

class LengthIndicator extends StatelessWidget {
  const LengthIndicator({
    super.key,
    required this.radius,
    required this.length,
    required this.code,
    required this.onTap,
  });

  final double radius;
  final int length;
  final int code;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Provider.of<AppColors>(context);
    return Positioned(
      bottom: 16,
      right: 16,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 130,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.pill,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_outward_rounded,
                color: colors.iconClr,
                size: 14,
              ),
              const Spacer(),
              Text(
                length == 1 ? "$length  Entry" : "$length Entries",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Product', color: colors.textClr),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

const List months = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec",
];

String getFormattedDate(DateTime date) {
  final minute = date.minute.toString().padLeft(2, '0');
  final suffix = date.hour >= 12 ? 'pm' : 'am';
  final hour12 = date.hour == 0
      ? 12
      : date.hour > 12
      ? date.hour - 12
      : date.hour;
  return "${date.day} ${months[date.month - 1]} ${date.year}, $hour12:$minute $suffix";
}
