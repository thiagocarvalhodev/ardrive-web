part of '../drive_detail_page.dart';

class FsEntrySideSheet extends StatelessWidget {
  final String driveId;
  final SelectedItem? maybeSelectedItem;
  FsEntrySideSheet({
    required this.driveId,
    this.maybeSelectedItem,
  });

  @override
  Widget build(BuildContext context) => Drawer(
        elevation: 1,
        child: BlocProvider<FsEntryInfoCubit>(
          // Specify a key to ensure a new cubit is provided when the folder/file id changes.
          key: ValueKey(
            driveId +
                '${maybeSelectedItem?.id ?? Random().nextInt(1000).toString()}',
          ),
          create: (context) => FsEntryInfoCubit(
            driveId: driveId,
            maybeSelectedItem: maybeSelectedItem,
            driveDao: context.read<DriveDao>(),
          ),
          child: DefaultTabController(
            length: 2,
            child: BlocBuilder<FsEntryInfoCubit, FsEntryInfoState>(
              builder: (context, state) => state is FsEntryInfoSuccess
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        ListTile(
                          title: Text(state.name),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => context
                                .read<DriveDetailCubit>()
                                .toggleSelectedItemDetails(),
                          ),
                        ),
                        TabBar(
                          tabs: [
                            Tab(
                                text: AppLocalizations.of(context)!
                                    .itemDetailsEmphasized),
                            Tab(
                                text: AppLocalizations.of(context)!
                                    .itemActivityEmphasized)
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildInfoTable(context, state),
                                  _buildTxTable(context, state),
                                ],
                              ),
                              _buildActivityTab(context, state),
                            ],
                          ),
                        )
                      ],
                    )
                  : const SizedBox(),
            ),
          ),
        ),
      );

  Widget _buildInfoTable(BuildContext context, FsEntryInfoSuccess state) =>
      DataTable(
        // Hide the data table header.
        headingRowHeight: 0,
        dataTextStyle: Theme.of(context).textTheme.subtitle2,
        columns: const [
          DataColumn(label: Text('')),
          DataColumn(label: Text('')),
        ],
        rows: [
          if (state is FsEntryInfoSuccess<Drive>) ...{
            DataRow(cells: [
              DataCell(Text(AppLocalizations.of(context)!.itemContains)),
              DataCell(
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    fileAndFolderCountsToString(
                        fileCount: (state as FsEntryDriveInfoSuccess)
                            .rootFolderTree
                            .getRecursiveFileCount(),
                        folderCount:
                            state.rootFolderTree.getRecursiveSubFolderCount()),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ]),
            DataRow(cells: [
              DataCell(Text(AppLocalizations.of(context)!.driveID)),
              DataCell(
                CopyIconButton(
                  tooltip: AppLocalizations.of(context)!.copyDriveID,
                  value: state.entry.id,
                ),
              ),
            ]),
            DataRow(cells: [
              DataCell(Text(AppLocalizations.of(context)!.privacy)),
              // Capitalise the privacy enums of drives for display.
              DataCell(
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    state.entry.privacy == DrivePrivacy.private
                        ? AppLocalizations.of(context)!.private
                        : AppLocalizations.of(context)!.public,
                  ),
                ),
              )
            ]),
          } else if (state is FsEntryInfoSuccess<FolderNode>) ...{
            DataRow(cells: [
              DataCell(Text(AppLocalizations.of(context)!.itemContains)),
              DataCell(
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    fileAndFolderCountsToString(
                      folderCount: state.entry.getRecursiveSubFolderCount(),
                      fileCount: state.entry.getRecursiveFileCount(),
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ]),
            DataRow(cells: [
              DataCell(Text(AppLocalizations.of(context)!.folderID)),
              DataCell(
                CopyIconButton(
                  tooltip: AppLocalizations.of(context)!.copyFolderID,
                  value: state.entry.folder.id,
                ),
              ),
            ]),
          } else if (state is FsEntryInfoSuccess<FileEntry>) ...{
            DataRow(cells: [
              DataCell(Text(AppLocalizations.of(context)!.fileID)),
              DataCell(
                CopyIconButton(
                  tooltip: AppLocalizations.of(context)!.copyFileID,
                  value: state.entry.id,
                ),
              ),
            ]),
            DataRow(cells: [
              DataCell(Text(AppLocalizations.of(context)!.fileSize)),
              DataCell(
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(filesize(state.entry.size)),
                ),
              )
            ]),
            DataRow(cells: [
              DataCell(Text(AppLocalizations.of(context)!.lastModified)),
              DataCell(
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    yMMdDateFormatter.format(state.entry.lastModifiedDate),
                  ),
                ),
              )
            ]),
          },
          DataRow(cells: [
            DataCell(Text(AppLocalizations.of(context)!.lastUpdated)),
            DataCell(
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  yMMdDateFormatter.format(state.lastUpdated),
                ),
              ),
            ),
          ]),
          DataRow(cells: [
            DataCell(Text(AppLocalizations.of(context)!.dateCreated)),
            DataCell(
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  yMMdDateFormatter.format(state.dateCreated),
                ),
              ),
            ),
          ]),
        ],
      );
  Widget _buildTxTable(BuildContext context, FsEntryInfoSuccess infoState) =>
      BlocProvider(
        create: (context) => FsEntryActivityCubit(
          driveId: driveId,
          driveDao: context.read<DriveDao>(),
          maybeSelectedItem: maybeSelectedItem,
        ),
        child: BlocBuilder<FsEntryActivityCubit, FsEntryActivityState>(
          builder: (context, state) {
            if (state is FsEntryActivitySuccess) {
              if (state.revisions.isNotEmpty) {
                final revision = state.revisions.last;
                return DataTable(
                  // Hide the data table header.

                  headingRowHeight: 0,
                  dataTextStyle: Theme.of(context).textTheme.subtitle2,
                  columns: const [
                    DataColumn(label: Text('')),
                    DataColumn(label: Text('')),
                  ],
                  rows: [
                    if (infoState is FsEntryDriveInfoSuccess) ...{
                      DataRow(cells: [
                        DataCell(Text(AppLocalizations.of(context)!.driveTxID)),
                        DataCell(
                          CopyIconButton(
                            tooltip:
                                AppLocalizations.of(context)!.copyDriveTxID,
                            value: revision.metadataTx.id,
                          ),
                        ),
                      ]),
                      DataRow(cells: [
                        DataCell(
                            Text(AppLocalizations.of(context)!.rootFolderTxID)),
                        DataCell(
                          CopyIconButton(
                            tooltip: AppLocalizations.of(context)!
                                .copyRootFolderTxID,
                            value: infoState.rootFolderRevision.metadataTxId,
                          ),
                        ),
                      ]),
                      if (revision.bundledIn != null)
                        DataRow(cells: [
                          DataCell(
                              Text(AppLocalizations.of(context)!.bundleTxID)),
                          DataCell(
                            CopyIconButton(
                              tooltip:
                                  AppLocalizations.of(context)!.copyBundleTxID,
                              value: revision.bundledIn,
                            ),
                          ),
                        ]),
                    } else if (infoState
                        is FsEntryInfoSuccess<FolderEntry>) ...{
                      DataRow(cells: [
                        DataCell(
                            Text(AppLocalizations.of(context)!.metadataTxID)),
                        DataCell(
                          CopyIconButton(
                            tooltip:
                                AppLocalizations.of(context)!.copyMetadataTxID,
                            value: revision.metadataTx.id,
                          ),
                        ),
                      ]),
                    } else if (infoState is FsEntryInfoSuccess<FileEntry>) ...{
                      DataRow(cells: [
                        DataCell(
                            Text(AppLocalizations.of(context)!.metadataTxID)),
                        DataCell(
                          CopyIconButton(
                            tooltip:
                                AppLocalizations.of(context)!.copyMetadataTxID,
                            value: revision.metadataTx.id,
                          ),
                        ),
                      ]),
                      DataRow(cells: [
                        DataCell(Text(AppLocalizations.of(context)!.dataTxID)),
                        DataCell(
                          CopyIconButton(
                            tooltip: AppLocalizations.of(context)!.copyDataTxID,
                            value: revision.dataTx.id,
                          ),
                        ),
                      ]),
                      if (revision.bundledIn != null)
                        DataRow(cells: [
                          DataCell(
                              Text(AppLocalizations.of(context)!.bundleTxID)),
                          DataCell(
                            CopyIconButton(
                              tooltip:
                                  AppLocalizations.of(context)!.copyBundleTxID,
                              value: revision.bundledIn,
                            ),
                          ),
                        ]),
                    },
                  ],
                );
              } else {
                return Center(
                    child: Text(
                        AppLocalizations.of(context)!.itemIsBeingProcesed));
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      );

  Widget _buildActivityTab(BuildContext context, FsEntryInfoSuccess state) =>
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: BlocProvider(
          create: (context) => FsEntryActivityCubit(
            driveId: driveId,
            maybeSelectedItem: maybeSelectedItem,
            driveDao: context.read<DriveDao>(),
          ),
          child: BlocBuilder<FsEntryActivityCubit, FsEntryActivityState>(
            builder: (context, state) {
              if (state is FsEntryActivitySuccess) {
                if (state.revisions.isNotEmpty) {
                  return ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      final revision = state.revisions[index];

                      late Widget content;
                      late Widget dateCreatedSubtitle;
                      late String revisionConfirmationStatus;

                      if (revision is DriveRevisionWithTransaction) {
                        switch (revision.action) {
                          case RevisionAction.create:
                            content = Text(AppLocalizations.of(context)!
                                .driveWasCreatedWithName(revision.name));
                            break;
                          case RevisionAction.rename:
                            content = Text(AppLocalizations.of(context)!
                                .driveWasRenamed(revision.name));
                            break;
                          default:
                            content = Text(
                                AppLocalizations.of(context)!.driveWasModified);
                        }

                        dateCreatedSubtitle = Text(
                            yMMdDateFormatter.format(revision.dateCreated));

                        revisionConfirmationStatus =
                            revision.confirmationStatus;
                      } else if (revision is FolderRevisionWithTransaction) {
                        switch (revision.action) {
                          case RevisionAction.create:
                            content = Text(AppLocalizations.of(context)!
                                .folderWasCreatedWithName(revision.name));
                            break;
                          case RevisionAction.rename:
                            content = Text(AppLocalizations.of(context)!
                                .folderWasRenamed(revision.name));
                            break;
                          case RevisionAction.move:
                            content = Text(
                                AppLocalizations.of(context)!.folderWasMoved);
                            break;
                          default:
                            content = Text(AppLocalizations.of(context)!
                                .folderWasModified);
                        }

                        dateCreatedSubtitle = Text(
                            yMMdDateFormatter.format(revision.dateCreated));

                        revisionConfirmationStatus =
                            revision.confirmationStatus;
                      } else if (revision is FileRevisionWithTransactions) {
                        switch (revision.action) {
                          case RevisionAction.create:
                            content = Text(AppLocalizations.of(context)!
                                .fileWasCreatedWithName(revision.name));
                            break;
                          case RevisionAction.rename:
                            content = Text(AppLocalizations.of(context)!
                                .fileWasRenamed(revision.name));
                            break;
                          case RevisionAction.move:
                            content = Text(
                                AppLocalizations.of(context)!.fileWasMoved);
                            break;
                          case RevisionAction.uploadNewVersion:
                            content = Text(AppLocalizations.of(context)!
                                .fileHadANewRevision);
                            break;
                          default:
                            content = Text(
                                AppLocalizations.of(context)!.fileWasModified);
                        }

                        dateCreatedSubtitle = Text(
                            yMMdDateFormatter.format(revision.dateCreated));

                        revisionConfirmationStatus = fileStatusFromTransactions(
                            revision.metadataTx, revision.dataTx);
                      }

                      late Widget statusIcon;
                      if (revisionConfirmationStatus ==
                          TransactionStatus.pending) {
                        statusIcon = Tooltip(
                          message: AppLocalizations.of(context)!.pending,
                          child: const Icon(Icons.pending),
                        );
                      } else if (revisionConfirmationStatus ==
                          TransactionStatus.confirmed) {
                        statusIcon = Tooltip(
                          message: AppLocalizations.of(context)!.confirmed,
                          child: const Icon(Icons.check),
                        );
                      } else if (revisionConfirmationStatus ==
                          TransactionStatus.failed) {
                        statusIcon = Tooltip(
                          message: AppLocalizations.of(context)!.failed,
                          child: const Icon(Icons.error_outline),
                        );
                      }

                      return ListTile(
                        title: DefaultTextStyle(
                          style: Theme.of(context).textTheme.subtitle2!,
                          child: content,
                        ),
                        subtitle: DefaultTextStyle(
                          style: Theme.of(context).textTheme.caption!,
                          child: dateCreatedSubtitle,
                        ),
                        trailing: statusIcon,
                      );
                    },
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: state.revisions.length,
                  );
                } else {
                  return Center(
                      child: Text(
                          AppLocalizations.of(context)!.itemIsBeingProcesed));
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      );
}

class CopyIconButton extends StatelessWidget {
  final String value;
  final String tooltip;

  CopyIconButton({required this.value, required this.tooltip});

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.centerRight,
        child: IconButton(
          icon: Icon(Icons.copy, color: Colors.black54),
          tooltip: tooltip,
          onPressed: () => Clipboard.setData(ClipboardData(text: value)),
        ),
      );
}
