import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:instaclone/helpers/helpers.dart';
import 'package:instaclone/screens/create_post/cubit/create_post_cubit.dart';
import 'package:instaclone/widgets/widgets.dart';

class CreatePostScreen extends StatelessWidget {
  static const String routeName = '/createPost';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  CreatePostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text('Create Post')),
        body: BlocConsumer<CreatePostCubit, CreatePostState>(
          listener: (context, state) {
            if (state.status == CreatePostStatus.success) {
              _formKey.currentState!.reset();
              context.read<CreatePostCubit>().reset();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 1),
                  content: Text('Post Created'),
                ),
              );
            } else if (state.status == CreatePostStatus.error) {
              showDialog(
                context: context,
                builder: (context) => ErrorDialog(
                  content: state.failure!.message,
                ),
              );
            }
            ;
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _selectPostImage(context),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 2,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: state.postImage != null
                          ? Image.file(state.postImage!, fit: BoxFit.cover)
                          : const Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: 120,
                            ),
                    ),
                  ),
                  if (state.status == CreatePostStatus.submitting)
                    const LinearProgressIndicator(),
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Caption',
                            ),
                            onChanged: (value) => context
                                .read<CreatePostCubit>()
                                .captionChanged(value),
                            validator: (value) => value!.trim().isEmpty
                                ? 'Caption cannot be empty.'
                                : null,
                          ),
                          SizedBox(height: 28),
                          MaterialButton(
                            onPressed: () => _submitForm(
                              context,
                              state.postImage!,
                              state.status == CreatePostStatus.submitting,
                            ),
                            elevation: 1,
                            color: Theme.of(context).primaryColor,
                            textColor: Colors.white,
                            child: Text('Post'),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _selectPostImage(BuildContext context) async {
    final pickedFile = await ImageHelper.pickImageFormGallery(
        context: context, cropstyle: CropStyle.circle, title: 'Create Post');
    if (pickedFile != null) {
      context.read<CreatePostCubit>().postImageChanged(
            pickedFile,
          );
    }
  }

  void _submitForm(BuildContext context, File postImage, bool isSubmitting) {
    if (_formKey.currentState!.validate() &&
        postImage != null &&
        !isSubmitting) {
      context.read<CreatePostCubit>().submit();
    }
  }
}
