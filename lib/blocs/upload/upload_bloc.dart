import 'dart:async';
import 'dart:typed_data';

import 'package:arweave/arweave.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../../repositories/repositories.dart';
import '../user/user_bloc.dart';

part 'upload_event.dart';
part 'upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final _uuid = Uuid();
  final UserBloc _userBloc;
  final DriveDao _driveDao;
  final ArweaveDao _arweaveDao;

  UploadBloc(
      {@required UserBloc userBloc,
      @required DriveDao driveDao,
      @required ArweaveDao arweaveDao})
      : _userBloc = userBloc,
        _driveDao = driveDao,
        _arweaveDao = arweaveDao,
        super(UploadInitial());

  @override
  Stream<UploadState> mapEventToState(
    UploadEvent event,
  ) async* {
    if (event is UploadFileToNetwork)
      yield* _mapUploadFileToNetworkToState(event);
  }

  Stream<UploadState> _mapUploadFileToNetworkToState(
      UploadFileToNetwork event) async* {
    yield UploadInProgress();

    final fileId = _uuid.v4();
    final wallet = (_userBloc.state as UserAuthenticated).userWallet;
    final transactions = <Transaction>[];

    if (await _driveDao.isDriveEmpty(event.driveId)) {
      final drive = await _driveDao.getDriveById(event.driveId);

      transactions.add(await _arweaveDao.prepareDriveEntity(
          drive.id, drive.rootFolderId, wallet));
    }

    if (await _driveDao.isFolderEmpty(event.parentFolderId)) {
      final parentFolder = await _driveDao.getFolderById(event.parentFolderId);

      transactions.add(await _arweaveDao.prepareFolderEntity(
        parentFolder.id,
        event.driveId,
        parentFolder.parentFolderId,
        parentFolder.name,
        wallet,
      ));
    }

    final uploadTxs = await _arweaveDao.prepareFileUpload(
      fileId,
      event.driveId,
      event.parentFolderId,
      event.fileName,
      event.fileSize,
      event.fileStream,
      wallet,
    );

    transactions.add(uploadTxs.entityTx);
    transactions.add(uploadTxs.dataTx);

    await _driveDao.createNewUploadedFileEntry(
      fileId,
      event.driveId,
      event.parentFolderId,
      event.fileName,
      event.filePath,
      event.fileSize,
    );
  }
}
