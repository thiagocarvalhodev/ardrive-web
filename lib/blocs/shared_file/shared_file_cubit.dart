import 'package:ardrive/entities/entities.dart';
import 'package:ardrive/services/services.dart';
import 'package:bloc/bloc.dart';
import 'package:cryptography/cryptography.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'shared_file_state.dart';

/// [SharedFileCubit] includes logic for displaying a file shared with another user.
class SharedFileCubit extends Cubit<SharedFileState> {
  final String? fileId;

  /// The [SecretKey] that can be used to decode the target file.
  ///
  /// `null` if the file is public.
  final SecretKey? fileKey;

  final ArweaveService? _arweave;

  SharedFileCubit({this.fileId, this.fileKey, ArweaveService? arweave})
      : _arweave = arweave,
        super(SharedFileLoadInProgress()) {
    loadFileDetails();
  }

  Future<void> loadFileDetails() async {
    emit(SharedFileLoadInProgress());

    final fileRevisions =
        await _arweave!.getAllFileEntitiesWithId(fileId!, fileKey);
    if (fileRevisions != null && fileRevisions.isNotEmpty) {
      fileRevisions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      emit(
        SharedFileLoadSuccess(
          file: fileRevisions.first,
          revisions: fileRevisions,
          fileKey: fileKey,
        ),
      );
    } else {
      emit(SharedFileNotFound());
    }
  }
}
